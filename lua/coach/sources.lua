-- Resolve a program descriptor to a list of sessions.
-- A "source" is one of:
--   nil / "builtin"           -> the builtin Neovim-manual sessions
--   "/path/to/dir" / "~/..."  -> every *.lua file in the directory is a session
--   "github:owner/repo[@ref]" -> clone to cache; load sessions from *.lua files
--
-- TODO: raw https://.../file.lua single-file source.

local builtin = require("coach.builtin")

local M = {}

--- Directory where cloned github programs live.
---@param program_name string
---@return string
function M.cache_dir(program_name)
	return vim.fn.stdpath("data") .. "/coach/programs/" .. program_name
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

--- Validate a set table, and say what is wrong with it if anything is.
---
--- The reason is the point: nine "skipped invalid set: win.1" warnings on startup
--- named neither the fault nor the fix, and the fault was one rename -- a program
--- written against the older `actions`/`action` spelling.
---@param s any
---@return boolean ok
---@return string|nil reason nil when ok
local function valid_set(s)
	if type(s) ~= "table" then
		return false, "not a table (got " .. type(s) .. ")"
	end
	if type(s.id) ~= "string" or #s.id == 0 then
		return false, "no `id` string"
	end
	if type(s.title) ~= "string" or #s.title == 0 then
		return false, "no `title` string"
	end
	if type(s.exercises) ~= "table" or #s.exercises == 0 then
		-- The one mistake worth naming outright, because it is a rename and not a
		-- debugging session: `actions` of `action` entries is what sets looked like
		-- before the vocabulary settled.
		if type(s.actions) == "table" then
			return false, "has `actions`, which is now `exercises` of `exercise` entries"
		end
		return false, "no non-empty `exercises` list"
	end
	for i, e in ipairs(s.exercises) do
		local where = ("exercise %d"):format(i)
		if type(e) ~= "table" then
			return false, where .. " is not a table"
		end
		if type(e.exercise) ~= "string" or #e.exercise == 0 then
			return false, where .. (type(e.action) == "string" and " has `action`, which is now `exercise`" or " has no `exercise` string")
		end
		for _, field in ipairs({ "display", "desc" }) do
			if type(e[field]) ~= "string" then
				return false, ("%s (%s) has no `%s` string"):format(where, e.exercise, field)
			end
		end
	end
	return true
end

M.valid_set = valid_set

--- Load one session file. Returns the (filtered) set list and the session's own
--- title, if it declared one, or nil on failure.
---
--- A session file returns its sets as a list and may name itself with a `title`
--- key alongside them: `return { title = "Moving Around", { id = "03.1", ... } }`.
--- The list part is read with ipairs, so the named key is not mistaken for a set.
---@param path string
---@return table[]|nil sets
---@return string|nil title
local function load_session_file(path)
	local ok, result = pcall(dofile, path)
	if not ok or type(result) ~= "table" then
		vim.notify("coach.nvim: failed to load session " .. path, vim.log.levels.WARN)
		return nil
	end
	local title = type(result.title) == "string" and #result.title > 0 and result.title or nil
	local sets_list = {}
	local skipped = {}
	for _, s in ipairs(result) do
		local ok_set, reason = valid_set(s)
		if ok_set then
			table.insert(sets_list, s)
		else
			local id = type(s) == "table" and type(s.id) == "string" and s.id or "?"
			table.insert(skipped, ("%s (%s)"):format(id, reason))
		end
	end

	-- One warning per file, however many sets are wrong. A program written against
	-- an older spelling of the set table is wrong in every set at once, and nine
	-- notifications at startup say nothing that one does not.
	if #skipped > 0 then
		local shown = vim.list_slice(skipped, 1, math.min(#skipped, 3))
		local more = #skipped > #shown and (" (+%d more)"):format(#skipped - #shown) or ""
		vim.notify(
			("coach.nvim: skipped %d invalid set(s) in %s: %s%s"):format(
				#skipped,
				path,
				table.concat(shown, ", "),
				more
			),
			vim.log.levels.WARN
		)
	end
	if #sets_list == 0 then
		return nil
	end
	return sets_list, title
end

--- Session name derived from a file path (stem, no extension).
---@param path string
---@return string
local function session_name_from_path(path)
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

--- Resolve a program to a list of sessions.
--- For github programs, reads from the cache dir; if not cached yet returns empty.
---@param program { name: string, source?: string }
---@return { name: string, title?: string, sets: table[] }[]
function M.load(program)
	local k = kind(program.source)

	local lua_files
	if k == "builtin" then
		local dir = builtin.default_program_dir()
		lua_files = dir and list_lua_files(dir) or {}
	elseif k == "github" then
		lua_files = list_lua_files_deep(M.cache_dir(program.name))
	else
		-- Root plus immediate subdirs, the same as a github program: a repo whose
		-- sessions live in a subdirectory used to lose all of them when the same
		-- checkout was named as a local path instead of cloned.
		lua_files = list_lua_files_deep(vim.fn.expand(program.source))
	end

	local sessions = {}
	for _, path in ipairs(lua_files) do
		local sets_list, title = load_session_file(path)
		if sets_list then
			table.insert(sessions, {
				name = session_name_from_path(path),
				title = title,
				sets = sets_list,
			})
		end
	end
	return sessions
end

--- Whether a program's content is available on disk (always true for builtin/dir).
---@param program { name: string, source?: string }
---@return boolean
function M.is_ready(program)
	local k = kind(program.source)
	if k == "builtin" then
		return builtin.default_program_dir() ~= nil
	end
	if k == "dir" then
		return vim.fn.isdirectory(vim.fn.expand(program.source)) == 1
	end
	-- github
	return vim.fn.isdirectory(M.cache_dir(program.name)) == 1
end

--- Async git clone into the cache dir.
---@param program { name: string, source: string }
---@param cb fun(ok: boolean, msg: string|nil)
function M.fetch(program, cb)
	if kind(program.source) ~= "github" then
		cb(true, nil)
		return
	end
	if M.is_ready(program) then
		cb(true, nil)
		return
	end
	if vim.fn.executable("git") == 0 then
		cb(false, "git not found on PATH")
		return
	end

	local repo, ref = parse_github(program.source)
	local url = "https://github.com/" .. repo .. ".git"
	local dest = M.cache_dir(program.name)
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
---@param program { name: string, source: string }
---@param cb fun(ok: boolean, msg: string|nil)
function M.update(program, cb)
	if kind(program.source) ~= "github" then
		cb(false, "only github programs can be updated")
		return
	end
	if not M.is_ready(program) then
		cb(false, "program not cached yet; nothing to update")
		return
	end

	vim.system({ "git", "pull", "--ff-only" }, { cwd = M.cache_dir(program.name), text = true }, function(res)
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
