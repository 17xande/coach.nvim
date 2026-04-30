-- Registry of configured exercise programs and the active session pointer.
-- Loads sessions on demand via `coach.sources` and swaps the set list on
-- `coach.sets` when the active session changes.

local sets = require("coach.sets")
local sources = require("coach.sources")

local M = {}

---@class coach.ProgramConfig
---@field name string
---@field source? string

---@type coach.ProgramConfig[]
local programs = {}

---@type table<string, { name: string, title?: string, sets: table[] }[]>
local sessions_by_program = {}

---@type { program: string, session: string }|nil
local active = nil

---@type string
local state_file = vim.fn.stdpath("data") .. "/coach/state.json"

--- Slot: called whenever the active session changes, with (program_name, session_name).
--- `init.lua` wires this to save progress, switch progress file, and re-render.
---@type fun(program_name: string, session_name: string)|nil
M._on_switch = nil

--- Ensure the parent directory of `path` exists.
---@param path string
local function ensure_parent(path)
	vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
end

--- Load persisted active pointer from disk.
---@return { program: string, session: string }|nil
local function load_state()
	local f = io.open(state_file, "r")
	if not f then
		return nil
	end
	local content = f:read("*a")
	f:close()
	local ok, data = pcall(vim.json.decode, content)
	if
		not ok
		or type(data) ~= "table"
		or type(data.active_program) ~= "string"
		or type(data.active_session) ~= "string"
	then
		return nil
	end
	return { program = data.active_program, session = data.active_session }
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
	f:write(vim.json.encode({ active_program = active.program, active_session = active.session }))
	f:close()
end

--- Reload a program's sessions from its source.
---@param program coach.ProgramConfig
local function reload_program(program)
	sessions_by_program[program.name] = sources.load(program)
end

--- Find a program config by name.
---@param name string
---@return coach.ProgramConfig|nil
local function find_program(name)
	for _, p in ipairs(programs) do
		if p.name == name then
			return p
		end
	end
	return nil
end

M._find_program = find_program

--- Configure programs. `on_ready` fires after all async github clones finish.
--- Unknown sources or missing `git` are warned and the program is left empty.
---@param opts { programs?: coach.ProgramConfig[], active?: string }
---@param on_ready? fun()
function M.configure(opts, on_ready)
	opts = opts or {}
	programs = {}
	sessions_by_program = {}

	local configured = opts.programs or {}
	-- Always include the builtin program (first) unless the user already declared it.
	local has_builtin = false
	for _, p in ipairs(configured) do
		if p.name == "user-manual" or p.source == "builtin" or p.source == nil and p.name == "user-manual" then
			has_builtin = true
			break
		end
	end
	if not has_builtin then
		table.insert(programs, { name = "user-manual" })
	end
	for _, p in ipairs(configured) do
		if type(p) == "table" and type(p.name) == "string" then
			table.insert(programs, { name = p.name, source = p.source })
		end
	end

	-- Load everything that's already available.
	for _, p in ipairs(programs) do
		if sources.is_ready(p) then
			reload_program(p)
		else
			sessions_by_program[p.name] = {}
		end
	end

	-- Fire async fetches for github programs that aren't cached.
	local pending = 0
	local done_cb = function() end
	local function maybe_done()
		pending = pending - 1
		if pending == 0 then
			done_cb()
		end
	end

	for _, p in ipairs(programs) do
		if sources.kind(p.source) == "github" and not sources.is_ready(p) then
			pending = pending + 1
			sources.fetch(p, function(ok, err)
				if ok then
					reload_program(p)
					vim.notify("coach.nvim: fetched program '" .. p.name .. "'", vim.log.levels.INFO)
				else
					vim.notify(
						"coach.nvim: failed to fetch '" .. p.name .. "': " .. (err or ""),
						vim.log.levels.WARN
					)
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
			table.insert(candidates, { program = requested:sub(1, slash - 1), session = requested:sub(slash + 1) })
		else
			table.insert(candidates, { program = requested })
		end
	end
	if persisted then
		table.insert(candidates, persisted)
	end
	-- Fallback: first available program/session.
	table.insert(candidates, {})

	active = nil
	for _, c in ipairs(candidates) do
		local name = c.program
		if not name then
			-- pick first program that has at least one session loaded
			for _, p in ipairs(programs) do
				if sessions_by_program[p.name] and #sessions_by_program[p.name] > 0 then
					name = p.name
					break
				end
			end
		end
		local program_sessions = name and sessions_by_program[name]
		if program_sessions and #program_sessions > 0 then
			local sess_name = c.session
			if sess_name then
				local found = nil
				for _, s in ipairs(program_sessions) do
					if s.name == sess_name then
						found = s
						break
					end
				end
				if found then
					active = { program = name, session = sess_name }
					sets.set_active_list(found.sets)
					break
				end
			else
				active = { program = name, session = program_sessions[1].name }
				sets.set_active_list(program_sessions[1].sets)
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
---@return { program: string, session: string }|nil
function M.get_active()
	return active and { program = active.program, session = active.session } or nil
end

--- List configured programs (shallow copy).
---@return coach.ProgramConfig[]
function M.list()
	local out = {}
	for _, p in ipairs(programs) do
		table.insert(out, { name = p.name, source = p.source })
	end
	return out
end

--- List sessions of a program.
---@param program_name string
---@return { name: string, title?: string, sets: table[] }[]
function M.sessions(program_name)
	return sessions_by_program[program_name] or {}
end

--- Flat list of { program, session } pairs across all programs (for pickers / completion).
---@return { program: string, session: string }[]
function M.all_session_pairs()
	local out = {}
	for _, p in ipairs(programs) do
		for _, s in ipairs(sessions_by_program[p.name] or {}) do
			table.insert(out, { program = p.name, session = s.name })
		end
	end
	return out
end

--- Switch the active session. Returns true on success.
---@param program_name string
---@param session_name string|nil When nil, the first session of the program is used.
---@return boolean ok, string|nil err
function M.switch(program_name, session_name)
	local program = find_program(program_name)
	if not program then
		return false, "unknown program: " .. program_name
	end
	local program_sessions = sessions_by_program[program_name] or {}
	if #program_sessions == 0 then
		if sources.kind(program.source) == "github" and not sources.is_ready(program) then
			return false, "program '" .. program_name .. "' is still being fetched"
		end
		return false, "program '" .. program_name .. "' has no sessions"
	end

	local chosen
	if session_name then
		for _, s in ipairs(program_sessions) do
			if s.name == session_name then
				chosen = s
				break
			end
		end
		if not chosen then
			return false, "unknown session '" .. session_name .. "' in program '" .. program_name .. "'"
		end
	else
		chosen = program_sessions[1]
	end

	active = { program = program_name, session = chosen.name }
	sets.set_active_list(chosen.sets)
	save_state()

	if M._on_switch then
		M._on_switch(active.program, active.session)
	end
	return true, nil
end

--- Refresh a github program's cache via `git pull`, then reload its sessions.
---@param program_name string
---@param cb fun(ok: boolean, err: string|nil)
function M.update(program_name, cb)
	local program = find_program(program_name)
	if not program then
		cb(false, "unknown program: " .. program_name)
		return
	end
	sources.update(program, function(ok, err)
		if ok then
			reload_program(program)
			-- If this program holds the active session, re-swap the set list.
			if active and active.program == program_name then
				for _, s in ipairs(sessions_by_program[program_name] or {}) do
					if s.name == active.session then
						sets.set_active_list(s.sets)
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
	programs = {}
	sessions_by_program = {}
	active = nil
end

--- Override the state file path (useful for tests).
---@param path string
function M._set_state_file(path)
	state_file = path
end

return M
