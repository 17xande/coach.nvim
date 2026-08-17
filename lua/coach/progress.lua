-- Per-session progress state and JSON persistence.
-- Each active session has its own progress file at:
--   {progress_dir}/{program_name}/{session_name}.json

local sets = require("coach.sets")

local M = {}

---@type number
local current_set_index = 1

---@type table<string, table<string, number>>
local set_counts = {}

---@type boolean
local window_visible = true

---@type boolean
local coaching_active = false

---@type string
local progress_dir = vim.fn.stdpath("data") .. "/coach/progress"

---@type string|nil
local progress_file = nil

---@type number
local required_reps = 20

--- Reset all in-memory state to defaults.
local function reset_state()
	current_set_index = 1
	set_counts = {}
	window_visible = true
	coaching_active = false
end

---@param dir string
---@param program_name string
---@param session_name string
---@return string
local function file_for(dir, program_name, session_name)
	return dir .. "/" .. program_name .. "/" .. session_name .. ".json"
end

--- Ensure the parent directory of `path` exists.
---@param path string
local function ensure_parent(path)
	vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
end

--- Configure defaults. Does not select an active file on its own.
---@param opts { progress_dir?: string, required_reps?: number, progress_file?: string }
function M.configure(opts)
	if opts.progress_dir then
		progress_dir = opts.progress_dir
	end
	if opts.required_reps then
		required_reps = opts.required_reps
	end
	if opts.progress_file then
		-- direct override (used by tests)
		progress_file = opts.progress_file
	end
end

--- Point at a specific program/session's progress file and load it.
--- Any already-loaded state is saved first.
---@param program_name string
---@param session_name string
function M.switch(program_name, session_name)
	if progress_file then
		M.save()
	end
	progress_file = file_for(progress_dir, program_name, session_name)
	M.load()
end

--- Load progress from the currently-active file.
function M.load()
	if not progress_file then
		reset_state()
		return
	end

	local f = io.open(progress_file, "r")
	if not f then
		reset_state()
		return
	end

	local content = f:read("*a")
	f:close()

	local ok, data = pcall(vim.json.decode, content)
	if not ok or type(data) ~= "table" then
		reset_state()
		return
	end

	current_set_index = data.current_set_index or 1
	set_counts = data.sets or {}
	window_visible = data.window_visible ~= false
	coaching_active = data.coaching_active == true

	local count = sets.count()
	if current_set_index < 1 then
		current_set_index = 1
	elseif count > 0 and current_set_index > count then
		current_set_index = count
	end
end

--- Save progress to the currently-active file.
function M.save()
	if not progress_file then
		return
	end

	-- vim.json.encode turns an empty Lua table into `[]`. Map empties to
	-- vim.empty_dict() so the file shape stays `{}` for external readers.
	local encoded_sets = vim.empty_dict()
	for id, counts in pairs(set_counts) do
		---@diagnostic disable-next-line: assign-type-mismatch, param-type-mismatch
		encoded_sets[id] = next(counts) and counts or vim.empty_dict()
	end

	local data = {
		current_set_index = current_set_index,
		sets = encoded_sets,
		window_visible = window_visible,
		coaching_active = coaching_active,
	}

	local json = vim.json.encode(data)
	ensure_parent(progress_file)
	local f = io.open(progress_file, "w")
	if not f then
		vim.notify("coach.nvim: failed to save progress", vim.log.levels.WARN)
		return
	end

	f:write(json)
	f:close()
end

---@return number
function M.get_set_index()
	return current_set_index
end

---@return table<string, number>
function M.get_counts()
	local s = sets.get(current_set_index)
	if not s then
		return {}
	end
	return set_counts[s.id] or {}
end

---@param exercise string
---@return number
function M.get_count(exercise)
	return M.get_counts()[exercise] or 0
end

---@param exercise string
---@return number
function M.increment(exercise)
	local s = sets.get(current_set_index)
	if not s then
		return 0
	end

	if not set_counts[s.id] then
		set_counts[s.id] = {}
	end

	local counts = set_counts[s.id]
	local current = counts[exercise] or 0
	local reps = s.required_reps or required_reps
	if current >= reps then
		return current
	end

	counts[exercise] = current + 1
	return counts[exercise]
end

--- Decrement an exercise's count by 1 (floored at 0).
--- Used by negative triggers — pressing a "bad habit" key undoes progress.
---@param exercise string
---@return number
function M.decrement(exercise)
	local s = sets.get(current_set_index)
	if not s then
		return 0
	end

	local counts = set_counts[s.id]
	if not counts then
		return 0
	end

	local current = counts[exercise] or 0
	if current <= 0 then
		counts[exercise] = 0
		return 0
	end

	counts[exercise] = current - 1
	return counts[exercise]
end

---@param exercise string
---@return boolean
function M.is_exercise_complete(exercise)
	local s = sets.get(current_set_index)
	local reps = (s and s.required_reps) or required_reps
	return M.get_count(exercise) >= reps
end

---@param shadowed? table<string, any>
---@return boolean
function M.is_set_complete(shadowed)
	shadowed = shadowed or {}
	local s = sets.get(current_set_index)
	if not s then
		return false
	end

	for _, e in ipairs(s.exercises) do
		if not shadowed[e.exercise] and not M.is_exercise_complete(e.exercise) then
			return false
		end
	end

	return true
end

---@return boolean
function M.advance()
	if current_set_index >= sets.count() then
		return false
	end
	current_set_index = current_set_index + 1
	M.save()
	return true
end

---@return boolean
function M.go_back()
	if current_set_index <= 1 then
		return false
	end
	current_set_index = current_set_index - 1
	M.save()
	return true
end

function M.reset_current()
	local s = sets.get(current_set_index)
	if s then
		set_counts[s.id] = {}
	end
	M.save()
end

--- Clear all progress for the active session only.
function M.reset_session()
	current_set_index = 1
	set_counts = {}
	M.save()
end

--- Clear all progress for every session of `program_name`.
--- Deletes the sibling session files on disk and clears the in-memory state
--- of the active session (which is then re-saved as empty).
---@param program_name string
function M.reset_program(program_name)
	local dir = progress_dir .. "/" .. program_name
	if vim.fn.isdirectory(dir) == 1 then
		for _, entry in ipairs(vim.fn.readdir(dir)) do
			if entry:sub(-5) == ".json" then
				os.remove(dir .. "/" .. entry)
			end
		end
	end
	current_set_index = 1
	set_counts = {}
	M.save()
end

---@return number
function M.get_required_reps()
	return required_reps
end

---@param index number
function M.go_to(index)
	local count = sets.count()
	if index < 1 then
		index = 1
	elseif count > 0 and index > count then
		index = count
	end
	current_set_index = index
	M.save()
end

---@return boolean
function M.is_window_visible()
	return window_visible
end

---@param visible boolean
function M.set_window_visible(visible)
	window_visible = visible
end

---@return boolean
function M.is_coaching_active()
	return coaching_active
end

---@param active boolean
function M.set_coaching_active(active)
	coaching_active = active
end

---@return table<string, table<string, number>>
function M.get_all_set_counts()
	return set_counts
end

return M
