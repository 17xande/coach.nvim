-- What track-action's parser emits for an exercise.
--
-- An exercise is a target for an *action string*, so an exercise that names a
-- string the parser never produces can never be completed: the user presses the
-- key, nothing is credited, and the set blocks `:CoachNext` forever. An audit found
-- 82 of 320 builtin exercises in that state.
--
-- `tests/emit_spec.lua` is the fence over the builtin content; `coach.health` asks
-- the same question at runtime, which is the only way to catch it in a third-party
-- program. Both go through here so there is one answer, not two.

local M = {}

--- track-action's parser module, or nil if it is not installed.
---@return table|nil
local function parser_mod()
	local ok, parser = pcall(require, "track-action.parser")
	return ok and parser or nil
end

M._parser_mod = parser_mod

--- track-action's mappings module, or nil if it is not installed. This is where an
--- `ex:` exercise gets its answer: those never reach the parser -- the tracker
--- classifies them from the CmdlineLeave path -- so asking the parser about one
--- says nothing, which is why they used to be exempt from this check entirely.
---@return table|nil
local function mappings_mod()
	local ok, mappings = pcall(require, "track-action.mappings")
	return ok and mappings or nil
end

--- Split an action string into the keys the tracker would hand the parser.
--- `<C-w>` is one key.
---@param str string
---@return string[]
function M.split_keys(str)
	local keys, i = {}, 1
	while i <= #str do
		if str:sub(i, i) == "<" then
			local close = str:find(">", i, true)
			if close then
				keys[#keys + 1] = str:sub(i, close)
				i = close + 1
			else
				keys[#keys + 1] = str:sub(i, i)
				i = i + 1
			end
		else
			keys[#keys + 1] = str:sub(i, i)
			i = i + 1
		end
	end
	return keys
end

--- The keystrokes a user would press to perform an exercise: a count becomes a
--- concrete digit, an operand a concrete character.
---@param exercise string
---@return string[]
function M.keystrokes_for(exercise)
	local typed = exercise:gsub("%[count%]", "3"):gsub("{[^}]*}", "a")
	return M.split_keys(typed)
end

--- What track-action emits for an exercise, or nil if it emits nothing -- and nil
--- too when track-action is not installed, since then there is nothing to ask.
--- Callers that need to tell those apart check `is_available`.
---
--- An `ex:` exercise is answered by the ex-command classifier and everything else
--- by the parser, which is the same split the tracker itself makes: an ex command
--- arrives on the CmdlineLeave path and never touches the grammar.
---@param exercise string
---@return string|nil
function M.emitted_for(exercise)
	local typed_ex = exercise:match("^ex:(.+)$")
	if typed_ex then
		local mappings = mappings_mod()
		return mappings and mappings.classify_ex_command(typed_ex) or nil
	end

	local mod = parser_mod()
	if not mod then
		return nil
	end

	local parser = mod.new()
	local action
	for _, key in ipairs(M.keystrokes_for(exercise)) do
		local result = parser:feed_key(key, "n")
		if result then
			action = result
		end
	end
	return action
end

--- Can the question be answered at all? False without track-action installed.
---@return boolean
function M.is_available()
	return parser_mod() ~= nil and mappings_mod() ~= nil
end

--- Every exercise in `sets_list` that track-action cannot emit.
---
--- `ex:` exercises used to be exempt here, on the grounds that the parser has
--- nothing to say about them -- but the *classifier* does, and while they went
--- unchecked nine builtin ones were dead: `ex:q` against an emitted `ex:quit`,
--- `ex:bnext` against `ex:buffer_next`, and so on. Exempting the half of the
--- content that a different function answers for is not a fence.
---@param sets_list table[] Set list, as `sets.get` returns them
---@return { set_id: string, exercise: string }[]
function M.unemittable(sets_list)
	local out = {}
	if not M.is_available() then
		return out
	end

	for _, set in ipairs(sets_list or {}) do
		for _, ex in ipairs(set.exercises or {}) do
			local action = ex.exercise
			if type(action) == "string" and M.emitted_for(action) ~= action then
				out[#out + 1] = { set_id = set.id, exercise = action }
			end
		end
	end
	return out
end

--- Every negative-rule trigger in `sets_list` that the parser cannot emit.
---
--- The same defect as a dead exercise and just as quiet: a rule whose trigger names
--- an action nothing emits never fires, so the habit it punishes goes unpunished and
--- nothing says so. Arrow-key triggers were in exactly that state while track-action
--- reported `<Down>` as raw bytes.
---
--- The `[N]` consecutive-press prefix is stripped through the rule engine's own
--- parser, so this cannot disagree with what the engine matches on.
---@param sets_list table[] Set list, as `sets.get` returns them
---@return { set_id: string, trigger: string, action: string }[]
function M.unemittable_triggers(sets_list)
	local out = {}
	if not M.is_available() then
		return out
	end

	local parse_trigger = require("coach.tracker")._parse_trigger

	for _, set in ipairs(sets_list or {}) do
		for _, rule in ipairs(set.negatives or {}) do
			for _, trigger in ipairs(rule.triggers or {}) do
				if type(trigger) == "string" then
					local action = parse_trigger(trigger)
					if M.emitted_for(action) ~= action then
						out[#out + 1] = { set_id = set.id, trigger = trigger, action = action }
					end
				end
			end
		end
	end
	return out
end

return M
