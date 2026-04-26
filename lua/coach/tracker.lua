-- Bridge to track-action.nvim

local exercises = require("coach.exercises")
local keybinds = require("coach.keybinds")
local log = require("coach.log")
local progress = require("coach.progress")
local window = require("coach.window")

local M = {}

--- The callback function references (needed for off_*_action)
---@type fun(action: string, data: table)|nil
local key_callback = nil
---@type fun(action: string, data: table)|nil
local cmd_callback = nil

--- Recent action history for anti-spam (ring buffer of last 3 actions)
local COOLDOWN = 3
---@type string[]
local recent_actions = {}

--- Cached reverse-alternatives map for the current exercise.
--- Maps formatted-display alternative (e.g. "<leader>|") → canonical action (e.g. "<C-w>v").
--- Invalidated whenever the exercise id changes.
---@type { id: string, reverse: table<string, string> }|nil
local alt_cache = nil

--- Next keybind string (set from init.lua)
---@type string
local next_key = "<leader>kn"

--- Set the keybind string shown in the completion hint
---@param key string
function M.set_next_key(key)
	next_key = key
end

--- Record an action in the recent history
---@param action string
local function push_recent(action)
	table.insert(recent_actions, action)
	if #recent_actions > COOLDOWN then
		table.remove(recent_actions, 1)
	end
end

--- Check if an action was performed too recently (anti-spam)
---@param action string
---@return boolean true if the action is on cooldown
local function is_on_cooldown(action)
	for _, recent in ipairs(recent_actions) do
		if recent == action then
			return true
		end
	end
	return false
end

--- Resolve which action string to use for exercise matching.
--- Prefers data.native (canonical native key) when available,
--- falling back to the raw action string from track-action.
---@param action string Action string from track-action callback
---@param data table|nil Data table from track-action (may contain .native)
---@return string The action string to match against exercise actions
function M.resolve_match_action(action, data)
	if data and data.native then
		return data.native
	end
	return action
end

--- Build a lookup set of actions for the current exercise
---@return table<string, boolean>
local function current_action_set()
	local exercise = exercises.get(progress.get_exercise_index())
	if not exercise then
		return {}
	end

	local set = {}
	for _, a in ipairs(exercise.actions) do
		set[a.action] = true
	end
	return set
end

--- Build a lookup map: action string → negative entry (with optional `threshold`).
---@return table<string, table>
local function current_negative_map()
	local exercise = exercises.get(progress.get_exercise_index())
	if not exercise or not exercise.negatives then
		return {}
	end

	local map = {}
	for _, n in ipairs(exercise.negatives) do
		map[n.action] = n
	end
	return map
end

--- Consecutive-press streak for the current negative.
--- Cleared when a non-matching action is seen, when the streak's negative changes,
--- or when the active exercise changes.
---@type { action: string, count: number }
local negative_streak = { action = "", count = 0 }

--- Reset the negative streak (called when exercise changes or on tracker stop).
local function reset_negative_streak()
	negative_streak = { action = "", count = 0 }
end

--- Update the streak for `match_action` against the current exercise's negatives.
--- Returns true if the streak just hit its threshold (caller should decrement).
--- Returns false otherwise (either not a negative, or streak below threshold).
---@param match_action string
---@param negatives table<string, table>
---@return boolean trigger, table|nil entry
function M._tick_negative(match_action, negatives)
	local entry = negatives[match_action]
	if not entry then
		reset_negative_streak()
		return false, nil
	end

	if negative_streak.action ~= match_action then
		negative_streak = { action = match_action, count = 1 }
	else
		negative_streak.count = negative_streak.count + 1
	end

	local threshold = entry.threshold or 1
	if negative_streak.count >= threshold then
		negative_streak.count = 0
		return true, entry
	end
	return false, entry
end

--- Test-only: inspect the current streak.
---@return string action, number count
function M._get_negative_streak()
	return negative_streak.action, negative_streak.count
end

--- Test-only: reset the streak.
function M._reset_negative_streak()
	reset_negative_streak()
end

--- Look up `action` in the alternatives of `exercise`.
--- Returns the canonical exercise action if `action` is a known alternative, else nil.
--- Result is cached per exercise id.
---@param action string
---@param exercise table
---@return string|nil
local function resolve_alternative(action, exercise)
	if not alt_cache or alt_cache.id ~= exercise.id then
		local forward = keybinds.get_alternatives(exercise)
		local reverse = {}
		for canonical, display_list in pairs(forward) do
			for _, disp in ipairs(display_list) do
				reverse[disp] = canonical
			end
		end
		alt_cache = { id = exercise.id, reverse = reverse }
		reset_negative_streak()
	end
	return alt_cache.reverse[action]
end

--- Handle an action from track-action.nvim
---@param action string
---@param data table
local function on_action(action, data)
	local action_set = current_action_set()
	local match_action = M.resolve_match_action(action, data)

	log.debug("on_action", { action = action, native = data and data.native, match = match_action })

	-- Negative trigger: a "bad habit" key the exercise wants to punish.
	-- A negative may declare `threshold = N` to require N consecutive presses
	-- before decrementing. The cooldown ring buffer does NOT apply here —
	-- threshold replaces that role, and decrement is floored at 0.
	local negatives = current_negative_map()
	local triggered, entry = M._tick_negative(match_action, negatives)
	if entry then
		push_recent(action)

		if not triggered then
			log.debug("on_action: negative streak building", {
				match = match_action,
				streak = select(2, M._get_negative_streak()),
				threshold = entry.threshold or 1,
			})
			return
		end

		local exercise = exercises.get(progress.get_exercise_index())
		if exercise then
			for _, a in ipairs(exercise.actions) do
				progress.decrement(a.action)
			end
			log.debug("on_action: negative triggered", { match = match_action, counts = progress.get_counts() })
		end

		vim.schedule(function()
			if window.is_open() then
				local ex = exercises.get(progress.get_exercise_index())
				if ex then
					local sh = keybinds.get_shadowed(ex)
					local alts = keybinds.get_alternatives(ex)
					local reps = ex.required_reps or progress.get_required_reps()
					window.set_message("Bad habit: " .. match_action .. " — progress decremented")
					window.render(ex, progress.get_counts(), reps, next_key, sh, alts)
				end
			end
		end)
		return
	end

	-- Track all actions in the recent history for cooldown purposes,
	-- but only process actions that belong to the current exercise.
	if not action_set[match_action] then
		-- Check if the action is an alternative keybinding for an exercise action
		-- (e.g. <leader>| mapped to <C-w>v should count toward <C-w>v).
		local exercise = exercises.get(progress.get_exercise_index())
		local alt = exercise and resolve_alternative(match_action, exercise)
		if not alt then
			log.debug("on_action: not in exercise, skip")
			push_recent(action)
			return
		end
		match_action = alt
	end

	if progress.is_action_complete(match_action) then
		log.debug("on_action: action already complete, skip")
		push_recent(action)
		return
	end

	-- Anti-spam: don't count if this action appears in the last N actions
	if is_on_cooldown(action) then
		log.debug("on_action: cooldown, skip")
		push_recent(action)
		vim.schedule(function()
			if window.is_open() then
				window.set_message("Repeated actions don't count")
				local exercise = exercises.get(progress.get_exercise_index())
				if exercise then
					local shadowed = keybinds.get_shadowed(exercise)
					local alternatives = keybinds.get_alternatives(exercise)
					local reps = exercise.required_reps or progress.get_required_reps()
					window.render(exercise, progress.get_counts(), reps, next_key, shadowed, alternatives)
				end
			end
		end)
		return
	end

	push_recent(action)

	local exercise = exercises.get(progress.get_exercise_index())
	local shadowed = exercise and keybinds.get_shadowed(exercise) or {}

	local was_complete = progress.is_exercise_complete(shadowed)
	progress.increment(match_action)
	local now_complete = progress.is_exercise_complete(shadowed)

	log.debug("on_action: counted", { match = match_action, counts = progress.get_counts(), complete = now_complete })

	-- Update window if open
	vim.schedule(function()
		if window.is_open() then
			local ex = exercises.get(progress.get_exercise_index())
			if ex then
				local sh = keybinds.get_shadowed(ex)
				local alts = keybinds.get_alternatives(ex)
				local reps = ex.required_reps or progress.get_required_reps()
				window.render(ex, progress.get_counts(), reps, next_key, sh, alts)
			end
		end

		-- Notify on exercise completion
		if not was_complete and now_complete then
			if not window.is_open() then
				vim.notify("coach.nvim: Exercise complete!", vim.log.levels.INFO)
			end
			progress.save()
		end
	end)
end

--- Start tracking by registering callbacks with track-action.nvim
function M.start()
	if key_callback then
		return
	end

	-- TODO: why pcall here? can't we just require this plugin once early in this file and use the refenrece?
	local ok, track_action = pcall(require, "track-action")
	if not ok then
		vim.notify("coach.nvim: track-action.nvim is required but not found", vim.log.levels.ERROR)
		return
	end

	recent_actions = {}
	reset_negative_streak()
	key_callback = on_action
	cmd_callback = on_action
	track_action.on_key_action(key_callback)
	track_action.on_cmd_action(cmd_callback)
end

--- Stop tracking by unregistering callbacks
function M.stop()
	if not key_callback then
		return
	end

	local ok, track_action = pcall(require, "track-action")
	if ok then
		track_action.off_key_action(key_callback)
		track_action.off_cmd_action(cmd_callback)
	end

	key_callback = nil
	cmd_callback = nil
	recent_actions = {}
	alt_cache = nil
	reset_negative_streak()
end

--- Check if tracker is active
---@return boolean
function M.is_active()
	return key_callback ~= nil
end

return M
