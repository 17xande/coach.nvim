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

--- Parse a trigger string like "[4]l" or "<Right>" into (action, threshold).
--- Plain triggers without a `[N]` prefix have threshold 1.
---@param trigger string
---@return string action, number threshold
function M._parse_trigger(trigger)
	local n, rest = trigger:match("^%[(%d+)%](.+)$")
	if n then
		return rest, tonumber(n) or 1
	end
	return trigger, 1
end

--- Compiled negative rule for the active exercise.
--- @class CompiledRule
--- @field triggers table<string, number>  -- action → threshold
--- @field decrement string[]               -- positive actions to decrement on fire
--- @field message string|nil               -- optional UI message
--- @field streak { action: string, count: number }  -- mutable per-rule runtime state

--- Cache of compiled rules for the current exercise.
---@type { id: string, rules: CompiledRule[] }|nil
local rules_cache = nil

--- Build (or return cached) compiled rules for the active exercise.
---@return CompiledRule[]
local function compiled_rules()
	local exercise = exercises.get(progress.get_exercise_index())
	if not exercise then
		return {}
	end
	if rules_cache and rules_cache.id == exercise.id then
		return rules_cache.rules
	end

	local rules = {}
	if exercise.negatives then
		for _, raw in ipairs(exercise.negatives) do
			local triggers = {}
			for _, t in ipairs(raw.triggers or {}) do
				local act, threshold = M._parse_trigger(t)
				triggers[act] = threshold
			end
			table.insert(rules, {
				triggers = triggers,
				decrement = raw.decrement or {},
				message = raw.message,
				streak = { action = "", count = 0 },
			})
		end
	end
	rules_cache = { id = exercise.id, rules = rules }
	return rules
end

--- Reset every rule's streak (called on exercise change, tracker start/stop).
local function reset_negative_streaks()
	if not rules_cache then
		return
	end
	for _, r in ipairs(rules_cache.rules) do
		r.streak = { action = "", count = 0 }
	end
end

--- Drop the rules cache so the next call rebuilds against the current exercise.
local function invalidate_rules_cache()
	rules_cache = nil
end

--- Tick every rule against `match_action`. Returns the list of rules that
--- fired this tick (caller should decrement and notify per rule).
--- A non-matching action resets a rule's streak; a different trigger inside
--- the same rule restarts that rule's streak at 1.
---@param match_action string
---@param rules CompiledRule[]
---@return CompiledRule[] fired
function M._tick_rules(match_action, rules)
	local fired = {}
	for _, r in ipairs(rules) do
		local threshold = r.triggers[match_action]
		if threshold then
			if r.streak.action == match_action then
				r.streak.count = r.streak.count + 1
			else
				r.streak = { action = match_action, count = 1 }
			end
			if r.streak.count >= threshold then
				r.streak = { action = "", count = 0 }
				table.insert(fired, r)
			end
		else
			r.streak = { action = "", count = 0 }
		end
	end
	return fired
end

--- Test helpers.
function M._reset_rules_cache()
	rules_cache = nil
end
function M._compile_rules_for(exercise)
	local rules = {}
	for _, raw in ipairs(exercise.negatives or {}) do
		local triggers = {}
		for _, t in ipairs(raw.triggers or {}) do
			local act, threshold = M._parse_trigger(t)
			triggers[act] = threshold
		end
		table.insert(rules, {
			triggers = triggers,
			decrement = raw.decrement or {},
			message = raw.message,
			streak = { action = "", count = 0 },
		})
	end
	return rules
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
		invalidate_rules_cache()
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

	-- Negative rules: a "bad habit" key the exercise wants to punish.
	-- Each rule lists `triggers` (with optional `[N]` consecutive-press prefix),
	-- `decrement` (which positive actions get decremented when it fires), and
	-- an optional `message`. The cooldown ring buffer does NOT apply here —
	-- the per-trigger threshold replaces that role, and decrement is floored at 0.
	local rules = compiled_rules()
	local is_trigger = false
	for _, r in ipairs(rules) do
		if r.triggers[match_action] then
			is_trigger = true
			break
		end
	end
	-- Always tick — non-trigger actions reset every rule's streak.
	local fired = M._tick_rules(match_action, rules)

	if is_trigger then
		push_recent(action)
		if #fired == 0 then
			log.debug("on_action: negative streak building", { match = match_action })
			return
		end

		for _, r in ipairs(fired) do
			for _, target in ipairs(r.decrement) do
				progress.decrement(target)
			end
		end
		log.debug("on_action: negative rule(s) fired", {
			match = match_action,
			fired = #fired,
			counts = progress.get_counts(),
		})

		local last_message = fired[#fired].message
			or ("Bad habit: " .. match_action .. " — progress decremented")
		vim.schedule(function()
			if window.is_open() then
				local ex = exercises.get(progress.get_exercise_index())
				if ex then
					local sh = keybinds.get_shadowed(ex)
					local alts = keybinds.get_alternatives(ex)
					local reps = ex.required_reps or progress.get_required_reps()
					window.set_message(last_message)
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
	reset_negative_streaks()
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
	reset_negative_streaks()
end

--- Check if tracker is active
---@return boolean
function M.is_active()
	return key_callback ~= nil
end

return M
