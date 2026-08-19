-- Which exercises coach can check for itself, and which it cannot.
--
-- An exercise is a target for an *action string*, so an exercise that names a
-- string track-action never produces can never be completed: the user presses the
-- key, nothing is credited, and the set blocks `:CoachNext` forever. An audit once
-- found 82 of 320 builtin exercises in that state, which is why there is a fence
-- at all.
--
-- **Half that fence moved out of this repo, and it is worth knowing why.** coach
-- used to answer "does this exercise emit?" by replaying its keys through
-- track-action's parser in-process. There is no parser now: Neovim's `CmdAtom`
-- reports what ran, and an action string is rendered *from a payload*, not derived
-- from keys. Nothing in-process can produce that payload -- `nvim_feedkeys` does
-- not publish atoms in any mode -- so the only way to ask the question is to type
-- the keys into a second Neovim over RPC. That is exactly what
-- `tests/vocabulary_spec.lua` in track-action.nvim does, for all 333 builtin
-- exercises and every shipped negative trigger.
--
-- So the split is now:
--
--   * **`ex:` exercises** are still answerable here, and cheaply: an ex atom
--     carries the text the user typed, so the whole question is what
--     `classify_ex_command` calls it -- a pure function, no editor needed. This is
--     also the half with the worst track record. Nine builtin ex exercises were
--     dead at once (`ex:q` where the tracker emits `ex:quit`, `ex:bnext` where it
--     emitted `ex:buffer_next`), found only when a user pressed `:q` and watched
--     nothing happen.
--   * **Every other exercise** is checked in track-action's repo tests, and not at
--     runtime. The cost is real and worth stating plainly: a *third-party* program
--     with a misspelled key exercise no longer gets a warning from
--     `:checkhealth coach`. There is no way to give it one that does not involve
--     spawning a Neovim from inside the user's Neovim.
--
-- `tests/emit_spec.lua` is the repo-side fence over the ex half and the notation
-- lint; `coach.health` asks the same questions at runtime through here, so there
-- is one answer rather than two.

local M = {}

--- track-action's mappings module, or nil if it is not installed.
---
--- This is where an `ex:` exercise gets its answer. Those never touch the
--- action-rendering path at all: an ex command arrives as its own atom type
--- carrying the typed cmdline, and the classifier names it.
---@return table|nil
local function mappings_mod()
	local ok, mappings = pcall(require, "track-action.mappings")
	return ok and mappings or nil
end

--- Split an action string into keys. `<C-w>` is one key.
---
--- Still here because `keystrokes_for` is still useful to anything driving an
--- exercise for real, and because the notation lint reads tokens.
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

--- Can this exercise's emission be checked without an editor to type into?
---
--- Only `ex:` ones. Exported because every caller has to branch on it, and a
--- caller that instead treated "no answer" as "emits fine" would be reporting a
--- vacuous OK over the half of the content nothing here checks.
---@param exercise string
---@return boolean
function M.is_checkable(exercise)
	return type(exercise) == "string" and exercise:match("^ex:") ~= nil
end

--- What track-action emits for an exercise, or nil if it emits nothing.
---
--- nil too when the exercise is not checkable here, or when track-action is not
--- installed -- callers that need to tell those apart ask `is_checkable` and
--- `is_available`.
---@param exercise string
---@return string|nil
function M.emitted_for(exercise)
	local typed_ex = type(exercise) == "string" and exercise:match("^ex:(.+)$")
	if not typed_ex then
		return nil
	end
	local mappings = mappings_mod()
	return mappings and mappings.classify_ex_command(typed_ex) or nil
end

--- Can the question be answered at all? False without track-action installed.
---@return boolean
function M.is_available()
	return mappings_mod() ~= nil
end

--- Every `ex:` exercise in `sets_list` that track-action cannot emit.
---
--- Scoped to the ex half, and named so at the call site: see the header for what
--- happened to the other half and why it cannot come back.
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
			if M.is_checkable(action) and M.emitted_for(action) ~= action then
				out[#out + 1] = { set_id = set.id, exercise = action }
			end
		end
	end
	return out
end

--- How many exercises in `sets_list` this repo can and cannot check.
---
--- So a health report can say "checked 41 of 138" rather than an unqualified OK
--- over content it never looked at. A fence that silently covers half its subject
--- reads as covering all of it.
---@param sets_list table[]
---@return integer checked, integer total
function M.coverage(sets_list)
	local checked, total = 0, 0
	for _, set in ipairs(sets_list or {}) do
		for _, ex in ipairs(set.exercises or {}) do
			if type(ex.exercise) == "string" then
				total = total + 1
				if M.is_checkable(ex.exercise) then
					checked = checked + 1
				end
			end
		end
	end
	return checked, total
end

--- Every exercise in `sets_list` that emits fine and still cannot be credited,
--- because coach matches the report against a different string than the exercise.
---
--- Emitting and being credited are two questions, and only the first had a fence.
--- Set 08.1 drills `:split`, `:close` and `:new`; track-action emits `ex:split` for
--- each and *also* reports `native = "<C-w>s"`, and coach preferred the native form
--- unconditionally -- so the exercise emitted perfectly and counted nothing. This
--- asks the second question: given the report track-action would produce, does
--- `resolve_match_action` land on the exercise the set actually wrote?
---
--- Under the current matching rule this can no longer report anything, because that
--- rule consults the set's own exercise list first -- which is the fix. It is a
--- regression fence on the rule, not a way to find bad content, and that is why
--- `:checkhealth coach` does not run it: there it would only ever print a vacuous
--- OK, which is what the other checks go out of their way not to do.
---@param sets_list table[] Set list, as `sets.get` returns them
---@return { set_id: string, exercise: string, credited: string }[]
function M.uncreditable(sets_list)
	local out = {}
	if not M.is_available() then
		return out
	end

	local resolve = require("coach.tracker").resolve_match_action
	local mappings = mappings_mod()
	if not mappings then
		return out
	end

	for _, set in ipairs(sets_list or {}) do
		local exercise_set = {}
		for _, ex in ipairs(set.exercises or {}) do
			if type(ex.exercise) == "string" then
				exercise_set[ex.exercise] = true
			end
		end

		for _, ex in ipairs(set.exercises or {}) do
			local action = ex.exercise
			-- Only ask of exercises that emit at all; a dead one is `unemittable`'s
			-- to report, and reporting it twice helps nobody.
			if M.is_checkable(action) and M.emitted_for(action) == action then
				-- The report track-action builds: an ex command carries the native
				-- keys that do the same thing.
				local typed_ex = action:match("^ex:(.+)$")
				local native = mappings.native_for_ex(typed_ex)
				local credited = resolve(action, { native = native }, exercise_set)
				if credited ~= action then
					out[#out + 1] = { set_id = set.id, exercise = action, credited = credited }
				end
			end
		end
	end
	return out
end

return M
