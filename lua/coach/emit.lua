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

--- What the parser emits when those keystrokes are typed, or nil if it emits
--- nothing -- and nil too when track-action is not installed, since then there is
--- no parser to ask. Callers that need to tell those apart check `is_available`.
---@param exercise string
---@return string|nil
function M.emitted_for(exercise)
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
	return parser_mod() ~= nil
end

--- Every exercise in `sets_list` that the parser cannot emit.
---
--- `ex:` exercises are exempt: they come from the CmdlineLeave path rather than the
--- parser, so the parser has nothing to say about them.
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
			if type(action) == "string" and not action:match("^ex:") then
				if M.emitted_for(action) ~= action then
					out[#out + 1] = { set_id = set.id, exercise = action }
				end
			end
		end
	end
	return out
end

return M
