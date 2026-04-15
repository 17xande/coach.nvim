-- Progress state management and JSON persistence

local exercises = require("coach.exercises")

local M = {}

--- In-memory state
---@type number
local current_exercise_index = 1

---@type table<string, table<string, number>>
local exercise_counts = {}

--TODO: welcome shown looks like it's tracked here, why also in init.lua?
---@type boolean
local welcome_shown = false

---@type boolean
local window_visible = true

---@type boolean
local coaching_active = false

---@type string
local progress_file = vim.fn.stdpath("data") .. "/coach_progress.json"

---@type number
local required_reps = 20

--- Configure the progress module
---@param opts { progress_file?: string, required_reps?: number }
function M.configure(opts)
	if opts.progress_file then
		progress_file = opts.progress_file
	end
	if opts.required_reps then
		required_reps = opts.required_reps
	end
end

--- Load progress from disk
function M.load()
	local f = io.open(progress_file, "r")
	if not f then
		current_exercise_index = 1
		exercise_counts = {}
		welcome_shown = false
		window_visible = true
		coaching_active = false
		return
	end

	local content = f:read("*a")
	f:close()

	local ok, data = pcall(vim.json.decode, content)
	if not ok or type(data) ~= "table" then
		current_exercise_index = 1
		exercise_counts = {}
		welcome_shown = false
		window_visible = true
		coaching_active = false
		return
	end

	current_exercise_index = data.current_exercise_index or 1
	exercise_counts = data.exercises or {}
	welcome_shown = data.welcome_shown == true
	window_visible = data.window_visible ~= false
	coaching_active = data.coaching_active == true

	-- Clamp index to valid range
	if current_exercise_index < 1 then
		current_exercise_index = 1
	elseif current_exercise_index > exercises.count() then
		current_exercise_index = exercises.count()
	end
end

--- Save progress to disk
function M.save()
	local data = {
		current_exercise_index = current_exercise_index,
		exercises = exercise_counts,
		welcome_shown = welcome_shown,
		window_visible = window_visible,
		coaching_active = coaching_active,
	}

	local json = vim.json.encode(data)
	local f = io.open(progress_file, "w")
	if not f then
		vim.notify("coach.nvim: failed to save progress", vim.log.levels.WARN)
		return
	end

	f:write(json)
	f:close()
end

--- Get the current exercise index
---@return number
function M.get_exercise_index()
	return current_exercise_index
end

--- Get action counts for the current exercise
---@return table<string, number>
function M.get_counts()
	local exercise = exercises.get(current_exercise_index)
	if not exercise then
		return {}
	end

	return exercise_counts[exercise.id] or {}
end

--- Get the count for a specific action in the current exercise
---@param action string
---@return number
function M.get_count(action)
	local counts = M.get_counts()
	return counts[action] or 0
end

--- Increment an action's count in the current exercise.
--- Does not increment past required_reps.
---@param action string
---@return number new_count
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

--- Check if a specific action is complete
---@param action string
---@return boolean
function M.is_action_complete(action)
	local exercise = exercises.get(current_exercise_index)
	local reps = (exercise and exercise.required_reps) or required_reps
	return M.get_count(action) >= reps
end

--- Check if the current exercise is complete.
--- Shadowed actions are skipped — they count as already done.
---@param shadowed? table<string, any> Set of shadowed action keys to ignore
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

--- Advance to the next exercise. Returns true if advanced, false if already at the end.
---@return boolean
function M.advance()
	if current_exercise_index >= exercises.count() then
		return false
	end

	current_exercise_index = current_exercise_index + 1
	M.save()
	return true
end

--- Go back to the previous exercise. Returns true if moved, false if already at the start.
---@return boolean
function M.go_back()
	if current_exercise_index <= 1 then
		return false
	end

	current_exercise_index = current_exercise_index - 1
	M.save()
	return true
end

--- Reset counts for the current exercise
function M.reset_current()
	local exercise = exercises.get(current_exercise_index)
	if exercise then
		exercise_counts[exercise.id] = {}
	end
	M.save()
end

--- Reset all progress (all counts, back to first exercise)
function M.reset_all()
	current_exercise_index = 1
	exercise_counts = {}
	M.save()
end

--- Get required reps
---@return number
function M.get_required_reps()
	return required_reps
end

--- Check if the welcome screen has never been shown
---@return boolean
function M.is_welcome_pending()
	return not welcome_shown
end

--- Mark the welcome screen as shown (caller should save)
function M.mark_welcome_shown()
	welcome_shown = true
end

--- Jump to a specific exercise index, clamped to valid range, and save
---@param index number
function M.go_to(index)
	local count = exercises.count()
	if index < 1 then
		index = 1
	elseif index > count then
		index = count
	end
	current_exercise_index = index
	M.save()
end

--- Check if the floating window should be visible
---@return boolean
function M.is_window_visible()
	return window_visible
end

--- Set whether the floating window should be visible
---@param visible boolean
function M.set_window_visible(visible)
	window_visible = visible
end

function M.is_coaching_active()
	return coaching_active
end

---@param active boolean
function M.set_coaching_active(active)
	coaching_active = active
end

--- Return the full exercise_counts table
---@return table<string, table<string, number>>
function M.get_all_exercise_counts()
	return exercise_counts
end

return M
