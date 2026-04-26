-- Resolve a set descriptor to a list of volumes.
-- A "source" is one of:
--   nil / "builtin"           -> the builtin Neovim-manual volumes
--   "/path/to/dir" / "~/..."  -> every *.lua file in the directory is a volume
--   "github:owner/repo[@ref]" -> clone to cache; load volumes from exercises/*.lua
--
-- TODO: raw https://.../file.lua single-file source.

local builtin = require("coach.builtin")

local M = {}

--- Directory where cloned github sets live.
---@param set_name string
---@return string
function M.cache_dir(set_name)
	return vim.fn.stdpath("data") .. "/coach/sets/" .. set_name
end

---@param source string|nil
---@return "builtin"|"dir"|"github"
local function kind(source)
	if source == nil or source == "" or source == "builtin" then
		return "builtin"
	end
	if source:sub(1, 7) == "github:" then
		return "github"
	end
	return "dir"
end

M.kind = kind

---@param source string
---@return string owner_repo, string|nil ref
local function parse_github(source)
	local spec = source:sub(8)
	local at = spec:find("@", 1, true)
	if at then
		return spec:sub(1, at - 1), spec:sub(at + 1)
	end
	return spec, nil
end

M.parse_github = parse_github

--- Validate a chapter table. Returns true if it has the required fields.
---@param ch any
---@return boolean
local function valid_chapter(ch)
	if type(ch) ~= "table" then
		return false
	end
	if type(ch.id) ~= "string" or #ch.id == 0 then
		return false
	end
	if type(ch.title) ~= "string" or #ch.title == 0 then
		return false
	end
	if type(ch.actions) ~= "table" or #ch.actions == 0 then
		return false
	end
	for _, a in ipairs(ch.actions) do
		if
			type(a) ~= "table"
			or type(a.action) ~= "string"
			or #a.action == 0
			or type(a.display) ~= "string"
			or type(a.desc) ~= "string"
		then
			return false
		end
	end
	return true
end

M.valid_chapter = valid_chapter

--- Load one volume file. Returns the (filtered) chapter list or nil on failure.
---@param path string
---@return table[]|nil
local function load_volume_file(path)
	local ok, result = pcall(dofile, path)
	if not ok or type(result) ~= "table" then
		vim.notify("coach.nvim: failed to load volume " .. path, vim.log.levels.WARN)
		return nil
	end
	local chapters = {}
	for _, ch in ipairs(result) do
		if valid_chapter(ch) then
			table.insert(chapters, ch)
		else
			vim.notify(
				"coach.nvim: skipped invalid chapter in " .. path .. ": " .. vim.inspect(ch and ch.id or "?"),
				vim.log.levels.WARN
			)
		end
	end
	if #chapters == 0 then
		return nil
	end
	return chapters
end

--- Volume name derived from a file path (stem, no extension).
---@param path string
---@return string
local function volume_name_from_path(path)
	local base = vim.fn.fnamemodify(path, ":t:r")
	return base
end

--- List *.lua volume files in a directory, sorted by filename.
---@param dir string
---@return string[]
local function list_lua_files(dir)
	local files = {}
	local expanded = vim.fn.expand(dir)
	if vim.fn.isdirectory(expanded) == 0 then
		return files
	end
	for _, entry in ipairs(vim.fn.readdir(expanded)) do
		if entry:sub(-4) == ".lua" then
			table.insert(files, expanded .. "/" .. entry)
		end
	end
	table.sort(files)
	return files
end

--- Collect *.lua files from a dir and all its immediate subdirectories.
--- Files at the root take precedence; subdir files are appended sorted by
--- subdir name then filename. Hidden directories (starting with ".") are skipped.
---@param root string
---@return string[]
local function list_lua_files_deep(root)
	local expanded = vim.fn.expand(root)
	if vim.fn.isdirectory(expanded) == 0 then
		return {}
	end

	local root_files = {}
	local subdir_files = {}
	local entries = vim.fn.readdir(expanded)

	for _, entry in ipairs(entries) do
		local full = expanded .. "/" .. entry
		if entry:sub(-4) == ".lua" then
			table.insert(root_files, full)
		elseif entry:sub(1, 1) ~= "." and vim.fn.isdirectory(full) == 1 then
			local sub = list_lua_files(full)
			for _, f in ipairs(sub) do
				table.insert(subdir_files, f)
			end
		end
	end

	table.sort(root_files)
	-- subdir_files is already sorted within each subdir; sort across subdirs by full path
	table.sort(subdir_files)

	local out = root_files
	for _, f in ipairs(subdir_files) do
		table.insert(out, f)
	end
	return out
end

M._list_lua_files = list_lua_files

--- Resolve a set to a list of volumes.
--- For github sets, reads from the cache dir; if not cached yet returns empty.
---@param set { name: string, source?: string }
---@return { name: string, title?: string, chapters: table[] }[]
function M.load(set)
	local k = kind(set.source)
	if k == "builtin" then
		return builtin.volumes()
	end

	local lua_files
	if k == "github" then
		-- Scan root + all immediate subdirs so any repo layout works.
		lua_files = list_lua_files_deep(M.cache_dir(set.name))
	else
		lua_files = list_lua_files(vim.fn.expand(set.source))
	end

	local volumes = {}
	for _, path in ipairs(lua_files) do
		local chapters = load_volume_file(path)
		if chapters then
			table.insert(volumes, {
				name = volume_name_from_path(path),
				chapters = chapters,
			})
		end
	end
	return volumes
end

--- Whether a set's content is available on disk (always true for builtin/dir).
---@param set { name: string, source?: string }
---@return boolean
function M.is_ready(set)
	local k = kind(set.source)
	if k == "builtin" then
		return true
	end
	if k == "dir" then
		return vim.fn.isdirectory(vim.fn.expand(set.source)) == 1
	end
	-- github
	return vim.fn.isdirectory(M.cache_dir(set.name)) == 1
end

--- Async git clone into the cache dir.
---@param set { name: string, source: string }
---@param cb fun(ok: boolean, msg: string|nil)
function M.fetch(set, cb)
	if kind(set.source) ~= "github" then
		cb(true, nil)
		return
	end
	if M.is_ready(set) then
		cb(true, nil)
		return
	end
	if vim.fn.executable("git") == 0 then
		cb(false, "git not found on PATH")
		return
	end

	local repo, ref = parse_github(set.source)
	local url = "https://github.com/" .. repo .. ".git"
	local dest = M.cache_dir(set.name)
	local parent = vim.fn.fnamemodify(dest, ":h")
	vim.fn.mkdir(parent, "p")

	local args = { "git", "clone", "--depth", "1" }
	if ref then
		table.insert(args, "--branch")
		table.insert(args, ref)
	end
	table.insert(args, url)
	table.insert(args, dest)

	vim.system(args, { text = true }, function(res)
		vim.schedule(function()
			if res.code == 0 then
				cb(true, nil)
			else
				cb(false, res.stderr or "git clone failed")
			end
		end)
	end)
end

--- Async `git pull` in the cache dir.
---@param set { name: string, source: string }
---@param cb fun(ok: boolean, msg: string|nil)
function M.update(set, cb)
	if kind(set.source) ~= "github" then
		cb(false, "only github sets can be updated")
		return
	end
	if not M.is_ready(set) then
		cb(false, "set not cached yet; nothing to update")
		return
	end

	vim.system({ "git", "pull", "--ff-only" }, { cwd = M.cache_dir(set.name), text = true }, function(res)
		vim.schedule(function()
			if res.code == 0 then
				cb(true, nil)
			else
				cb(false, res.stderr or "git pull failed")
			end
		end)
	end)
end

return M
