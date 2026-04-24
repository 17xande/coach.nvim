-- Per-volume progress state and JSON persistence.
-- Each active volume has its own progress file at:
--   {progress_dir}/{set_name}/{volume_name}.json

local exercises = require("coach.exercises")

local M = {}

---@type number
local current_exercise_index = 1

---@type table<string, table<string, number>>
local exercise_counts = {}

---@type boolean
local welcome_shown = false

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
	current_exercise_index = 1
	exercise_counts = {}
	welcome_shown = false
	window_visible = true
	coaching_active = false
end

---@param dir string
---@param set_name string
---@param volume_name string
---@return string
local function file_for(dir, set_name, volume_name)
	return dir .. "/" .. set_name .. "/" .. volume_name .. ".json"
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

--- Point at a specific set/volume's progress file and load it.
--- Any already-loaded state is saved first.
---@param set_name string
---@param volume_name string
function M.switch(set_name, volume_name)
	if progress_file then
		M.save()
	end
	progress_file = file_for(progress_dir, set_name, volume_name)
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

	current_exercise_index = data.current_exercise_index or 1
	exercise_counts = data.exercises or {}
	welcome_shown = data.welcome_shown == true
	window_visible = data.window_visible ~= false
	coaching_active = data.coaching_active == true

	local count = exercises.count()
	if current_exercise_index < 1 then
		current_exercise_index = 1
	elseif count > 0 and current_exercise_index > count then
		current_exercise_index = count
	end
end

--- Save progress to the currently-active file.
function M.save()
	if not progress_file then
		return
	end

	local data = {
		current_exercise_index = current_exercise_index,
		exercises = exercise_counts,
		welcome_shown = welcome_shown,
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
function M.get_exercise_index()
	return current_exercise_index
end

---@return table<string, number>
function M.get_counts()
	local exercise = exercises.get(current_exercise_index)
	if not exercise then
		return {}
	end
	return exercise_counts[exercise.id] or {}
end

---@param action string
---@return number
function M.get_count(action)
	return M.get_counts()[action] or 0
end

---@param action string
---@return number
function M.increment(action)
	local exercise = exercises.get(current_exercise_index)
	if not exercise then
		return 0
	end

	if not exercise_counts[exercise.id] then
		exercise_counts[exercise.id] = {}
	end

	local counts = exercise_counts[exercise.id]
	local current = counts[action] or 0
	local reps = exercise.required_reps or required_reps
	if current >= reps then
		return current
	end

	counts[action] = current + 1
	return counts[action]
end

---@param action string
---@return boolean
function M.is_action_complete(action)
	local exercise = exercises.get(current_exercise_index)
	local reps = (exercise and exercise.required_reps) or required_reps
	return M.get_count(action) >= reps
end

---@param shadowed? table<string, any>
---@return boolean
function M.is_exercise_complete(shadowed)
	shadowed = shadowed or {}
	local exercise = exercises.get(current_exercise_index)
	if not exercise then
		return false
	end

	for _, a in ipairs(exercise.actions) do
		if not shadowed[a.action] and not M.is_action_complete(a.action) then
			return false
		end
	end

	return true
end

---@return boolean
function M.advance()
	if current_exercise_index >= exercises.count() then
		return false
	end
	current_exercise_index = current_exercise_index + 1
	M.save()
	return true
end

---@return boolean
function M.go_back()
	if current_exercise_index <= 1 then
		return false
	end
	current_exercise_index = current_exercise_index - 1
	M.save()
	return true
end

function M.reset_current()
	local exercise = exercises.get(current_exercise_index)
	if exercise then
		exercise_counts[exercise.id] = {}
	end
	M.save()
end

function M.reset_all()
	current_exercise_index = 1
	exercise_counts = {}
	M.save()
end

---@return number
function M.get_required_reps()
	return required_reps
end

---@return boolean
function M.is_welcome_pending()
	return not welcome_shown
end

function M.mark_welcome_shown()
	welcome_shown = true
end

---@param index number
function M.go_to(index)
	local count = exercises.count()
	if index < 1 then
		index = 1
	elseif count > 0 and index > count then
		index = count
	end
	current_exercise_index = index
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
function M.get_all_exercise_counts()
	return exercise_counts
end

return M
