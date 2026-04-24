-- Registry of configured exercise sets and the active volume pointer.
-- Loads volumes on demand via `coach.sources` and swaps the chapter list on
-- `coach.exercises` when the active volume changes.

local exercises = require("coach.exercises")
local sources = require("coach.sources")

local M = {}

---@class coach.SetConfig
---@field name string
---@field source? string

---@type coach.SetConfig[]
local sets = {}

---@type table<string, { name: string, title?: string, chapters: table[] }[]>
local volumes_by_set = {}

---@type { set: string, volume: string }|nil
local active = nil

---@type string
local state_file = vim.fn.stdpath("data") .. "/coach/state.json"

--- Slot: called whenever the active volume changes, with (set_name, volume_name).
--- `init.lua` wires this to save progress, switch progress file, and re-render.
---@type fun(set_name: string, volume_name: string)|nil
M._on_switch = nil

--- Ensure the parent directory of `path` exists.
---@param path string
local function ensure_parent(path)
	vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
end

--- Load persisted active pointer from disk.
---@return { set: string, volume: string }|nil
local function load_state()
	local f = io.open(state_file, "r")
	if not f then
		return nil
	end
	local content = f:read("*a")
	f:close()
	local ok, data = pcall(vim.json.decode, content)
	if not ok or type(data) ~= "table" or type(data.active_set) ~= "string" or type(data.active_volume) ~= "string" then
		return nil
	end
	return { set = data.active_set, volume = data.active_volume }
end

--- Persist active pointer to disk.
local function save_state()
	if not active then
		return
	end
	ensure_parent(state_file)
	local f = io.open(state_file, "w")
	if not f then
		return
	end
	f:write(vim.json.encode({ active_set = active.set, active_volume = active.volume }))
	f:close()
end

--- Reload a set's volumes from its source.
---@param set coach.SetConfig
local function reload_set(set)
	volumes_by_set[set.name] = sources.load(set)
end

--- Find a set config by name.
---@param name string
---@return coach.SetConfig|nil
local function find_set(name)
	for _, s in ipairs(sets) do
		if s.name == name then
			return s
		end
	end
	return nil
end

M._find_set = find_set

--- Configure sets. `on_ready` fires after all async github clones finish.
--- Unknown sources or missing `git` are warned and the set is left empty.
---@param opts { sets?: coach.SetConfig[], active?: string }
---@param on_ready? fun()
function M.configure(opts, on_ready)
	opts = opts or {}
	sets = {}
	volumes_by_set = {}

	local configured = opts.sets or {}
	-- Always include the builtin set (first) unless the user already declared it.
	local has_builtin = false
	for _, s in ipairs(configured) do
		if s.name == "neovim-manual" or s.source == "builtin" or s.source == nil and s.name == "neovim-manual" then
			has_builtin = true
			break
		end
	end
	if not has_builtin then
		table.insert(sets, { name = "neovim-manual" })
	end
	for _, s in ipairs(configured) do
		if type(s) == "table" and type(s.name) == "string" then
			table.insert(sets, { name = s.name, source = s.source })
		end
	end

	-- Load everything that's already available.
	for _, s in ipairs(sets) do
		if sources.is_ready(s) then
			reload_set(s)
		else
			volumes_by_set[s.name] = {}
		end
	end

	-- Fire async fetches for github sets that aren't cached.
	local pending = 0
	local done_cb = function() end
	local function maybe_done()
		pending = pending - 1
		if pending == 0 then
			done_cb()
		end
	end

	for _, s in ipairs(sets) do
		if sources.kind(s.source) == "github" and not sources.is_ready(s) then
			pending = pending + 1
			sources.fetch(s, function(ok, err)
				if ok then
					reload_set(s)
					vim.notify("coach.nvim: fetched set '" .. s.name .. "'", vim.log.levels.INFO)
				else
					vim.notify("coach.nvim: failed to fetch '" .. s.name .. "': " .. (err or ""), vim.log.levels.WARN)
				end
				maybe_done()
			end)
		end
	end

	-- Resolve the active pointer.
	local requested = opts.active
	local persisted = load_state()
	local candidates = {}
	if requested then
		local slash = requested:find("/", 1, true)
		if slash then
			table.insert(candidates, { set = requested:sub(1, slash - 1), volume = requested:sub(slash + 1) })
		else
			table.insert(candidates, { set = requested })
		end
	end
	if persisted then
		table.insert(candidates, persisted)
	end
	-- Fallback: first available set/volume.
	table.insert(candidates, {})

	active = nil
	for _, c in ipairs(candidates) do
		local name = c.set
		if not name then
			-- pick first set that has at least one volume loaded
			for _, s in ipairs(sets) do
				if volumes_by_set[s.name] and #volumes_by_set[s.name] > 0 then
					name = s.name
					break
				end
			end
		end
		local set_volumes = name and volumes_by_set[name]
		if set_volumes and #set_volumes > 0 then
			local vol_name = c.volume
			if vol_name then
				local found = nil
				for _, v in ipairs(set_volumes) do
					if v.name == vol_name then
						found = v
						break
					end
				end
				if found then
					active = { set = name, volume = vol_name }
					exercises.set_active_chapters(found.chapters)
					break
				end
			else
				active = { set = name, volume = set_volumes[1].name }
				exercises.set_active_chapters(set_volumes[1].chapters)
				break
			end
		end
	end

	if on_ready then
		if pending == 0 then
			on_ready()
		else
			done_cb = on_ready
		end
	end
end

--- Current active pointer, or nil if nothing is available.
---@return { set: string, volume: string }|nil
function M.get_active()
	return active and { set = active.set, volume = active.volume } or nil
end

--- List configured sets (shallow copy).
---@return coach.SetConfig[]
function M.list()
	local out = {}
	for _, s in ipairs(sets) do
		table.insert(out, { name = s.name, source = s.source })
	end
	return out
end

--- List volumes of a set.
---@param set_name string
---@return { name: string, title?: string, chapters: table[] }[]
function M.volumes(set_name)
	return volumes_by_set[set_name] or {}
end

--- Flat list of { set, volume } pairs across all sets (for pickers / completion).
---@return { set: string, volume: string }[]
function M.all_volume_pairs()
	local out = {}
	for _, s in ipairs(sets) do
		for _, v in ipairs(volumes_by_set[s.name] or {}) do
			table.insert(out, { set = s.name, volume = v.name })
		end
	end
	return out
end

--- Switch the active volume. Returns true on success.
---@param set_name string
---@param volume_name string|nil When nil, the first volume of the set is used.
---@return boolean ok, string|nil err
function M.switch(set_name, volume_name)
	local set = find_set(set_name)
	if not set then
		return false, "unknown set: " .. set_name
	end
	local set_volumes = volumes_by_set[set_name] or {}
	if #set_volumes == 0 then
		if sources.kind(set.source) == "github" and not sources.is_ready(set) then
			return false, "set '" .. set_name .. "' is still being fetched"
		end
		return false, "set '" .. set_name .. "' has no volumes"
	end

	local chosen
	if volume_name then
		for _, v in ipairs(set_volumes) do
			if v.name == volume_name then
				chosen = v
				break
			end
		end
		if not chosen then
			return false, "unknown volume '" .. volume_name .. "' in set '" .. set_name .. "'"
		end
	else
		chosen = set_volumes[1]
	end

	active = { set = set_name, volume = chosen.name }
	exercises.set_active_chapters(chosen.chapters)
	save_state()

	if M._on_switch then
		M._on_switch(active.set, active.volume)
	end
	return true, nil
end

--- Refresh a github set's cache via `git pull`, then reload its volumes.
---@param set_name string
---@param cb fun(ok: boolean, err: string|nil)
function M.update(set_name, cb)
	local set = find_set(set_name)
	if not set then
		cb(false, "unknown set: " .. set_name)
		return
	end
	sources.update(set, function(ok, err)
		if ok then
			reload_set(set)
			-- If this set holds the active volume, re-swap chapters.
			if active and active.set == set_name then
				for _, v in ipairs(volumes_by_set[set_name] or {}) do
					if v.name == active.volume then
						exercises.set_active_chapters(v.chapters)
						break
					end
				end
			end
		end
		cb(ok, err)
	end)
end

--- Testing hook: clear all state.
function M._reset()
	sets = {}
	volumes_by_set = {}
	active = nil
end

--- Override the state file path (useful for tests).
---@param path string
function M._set_state_file(path)
	state_file = path
end

return M
