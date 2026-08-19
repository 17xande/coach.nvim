-- Emit spec: can every builtin exercise actually be completed?
-- Run: nvim --headless -u tests/minimal_init.lua -c "luafile tests/emit_spec.lua"
--
-- An exercise is a target for an action string that track-action.nvim emits. If it
-- targets a string nothing ever produces, the row can never fill: the user presses
-- the key, nothing is credited, and the set blocks `:CoachNext` forever.
--
-- That is not hypothetical. An audit found **82 of 320 builtin exercises** in this
-- state -- 42% of the drill content -- across six clusters, every one of them a gap
-- in track-action's command tables rather than a typo here.
--
-- **This spec now covers the `ex:` half of that question, and it is important to
-- know where the other half went.** coach used to answer "does this exercise emit?"
-- by replaying its keys through track-action's parser in-process. There is no
-- parser: Neovim's `CmdAtom` reports what ran, an action string is rendered from
-- that payload, and nothing running inside this Neovim can produce one --
-- `nvim_feedkeys` publishes no atoms in any mode. The key half is therefore fenced
-- in **`track-action.nvim/tests/vocabulary_spec.lua`**, which types all 333
-- exercises into a *second* Neovim over RPC and renders what comes back. Every
-- shipped negative trigger goes through the same fence there.
--
-- What is left here is the half that needs no editor at all: an ex atom carries the
-- text the user typed, so the whole question is what `classify_ex_command` calls it.
-- It is also the half with the worst record -- nine builtin ex exercises were dead
-- at once (`ex:q` against an emitted `ex:quit`, `ex:bnext` against
-- `ex:buffer_next`), found only when a user pressed `:q` and watched nothing happen.
--
-- It needs track-action.nvim on the runtimepath and skips itself without it, so the
-- suite still runs for someone who has only this plugin checked out.

local h = require("harness")
local describe, it, eq = h.describe, h.it, h.eq

-- track-action is a runtime dependency but not a test-harness one, so find it if it
-- is not already on the runtimepath: a sibling checkout is where it lives during
-- development. Skip the whole spec if there is none, rather than fail a suite run
-- for someone who has only this plugin.
local ok_ta = pcall(require, "track-action.mappings")
if not ok_ta then
	local sibling = vim.fn.fnamemodify(vim.fn.getcwd(), ":h") .. "/track-action.nvim"
	if vim.fn.isdirectory(sibling) == 1 then
		vim.opt.runtimepath:append(sibling)
		ok_ta = pcall(require, "track-action.mappings")
	end
end
if not ok_ta then
	print("emit_spec: track-action.nvim not found, skipping")
	h.summary()
	return
end
require("track-action.config").setup({ debug = false })

-- The classification lives in `coach.emit`, because `:checkhealth coach` asks the
-- same question at runtime and two implementations of "what does this exercise
-- emit" would eventually disagree. What this spec owns is the *content* check.
local emit = require("coach.emit")
local emitted_for = emit.emitted_for

--- Every exercise of every builtin session, in file order.
---@return table[] { session, set_id, exercise, display }
local function builtin_exercises()
	local out = {}
	local files = vim.fn.glob(vim.fn.getcwd() .. "/exercise-programs/user-manual/*.lua", false, true)
	table.sort(files)
	for _, file in ipairs(files) do
		local session = vim.fn.fnamemodify(file, ":t:r")
		for _, set in ipairs(dofile(file)) do
			for _, ex in ipairs(set.exercises or {}) do
				out[#out + 1] = {
					session = session,
					set_id = set.id,
					exercise = ex.exercise,
					display = ex.display,
				}
			end
		end
	end
	return out
end

local EXERCISES = builtin_exercises()

describe("every builtin exercise can be emitted", function()
	it("there are exercises to check at all", function()
		-- A glob that silently matched nothing would make every test below vacuous.
		eq(true, #EXERCISES > 100, "expected the six builtin sessions, got " .. #EXERCISES)
	end)

	-- One test per exercise rather than one summarizing test, so a failure names the
	-- set and the exercise instead of a count.
	--
	-- `ex:` only. They used to be *skipped* here, on the grounds that they come from
	-- the cmdline path and the parser had nothing to say about them -- and while they
	-- went unchecked nine of them were dead. Now they are the only ones this spec can
	-- reach, for the opposite reason: they are the ones that need no editor.
	local checkable = 0
	for _, e in ipairs(EXERCISES) do
		if emit.is_checkable(e.exercise) then
			checkable = checkable + 1
			it(("%s %s  %s"):format(e.session, e.set_id, e.exercise), function()
				eq(e.exercise, emitted_for(e.exercise))
			end)
		end
	end

	it("says out loud how much of the content it covers", function()
		-- A fence that silently covers a third of its subject reads as covering all
		-- of it. The number is printed so a green run cannot be mistaken for one.
		print(("      checked %d of %d exercises here (the `ex:` ones); the other %d are fenced in track-action's tests/vocabulary_spec.lua"):format(
			checkable,
			#EXERCISES,
			#EXERCISES - checkable
		))
		eq(true, checkable > 100, "expected the ex: exercises to be found, got " .. checkable)
	end)
end)

describe("exercise notation", function()
	-- Vim's convention, which the manual follows: braces for a required argument,
	-- brackets for an optional one. A count is optional and an operand is not, so a
	-- count is spelled `[count]` -- never `{N}` or `{count}`, which read as required
	-- and which track-action does not emit either way.
	for _, e in ipairs(EXERCISES) do
		local wrong = e.exercise:match("{%u+}") or e.exercise:match("{count}")
		if wrong then
			it(("%s %s  %s spells its count %s"):format(e.session, e.set_id, e.exercise, wrong), function()
				eq("[count]", wrong, "counts are optional, so they use bracket notation")
			end)
		end
	end

	-- `display` is what the user reads in the window, and may legitimately differ
	-- from the action string. What it must not do is promise a count the exercise
	-- cannot credit: `display = "{N}go"` against `exercise = "go"` told the user to
	-- press `3go`, which emits `[count]go` and counted nothing.
	for _, e in ipairs(EXERCISES) do
		-- An ex command takes its count as an argument (`:undo 5`), not as a Vim
		-- count, and nothing about it flows through the parser, so it is exempt.
		local counted_display = e.display
			and not e.exercise:match("^ex:")
			and (e.display:match("{%u+}") or e.display:match("%[count%]"))
		if counted_display then
			it(("%s %s  display %s takes a count, so the exercise must"):format(e.session, e.set_id, e.display), function()
				eq("[count]", e.exercise:sub(1, 7))
			end)
		end
	end

	for _, e in ipairs(EXERCISES) do
		if not e.display or e.display == "" then
			it(("%s %s  %s has a display string"):format(e.session, e.set_id, e.exercise), function()
				eq(true, false, "display is missing")
			end)
		end
	end
end)

-- =========================================================================
-- Creditable, not merely emittable
-- =========================================================================

--- Emitting is half the question. `:split` emits `ex:split` and always did; what
--- coach then matched on was `<C-w>s`, the native equivalent track-action reports
--- alongside it, so set 08.1 could not be completed either. This asks whether the
--- report a real keypress produces lands back on the exercise that was written.
describe("every builtin exercise can be credited, not just emitted", function()
	local emit_mod = require("coach.emit")

	local BY_SESSION = {}
	do
		local files = vim.fn.glob(vim.fn.getcwd() .. "/exercise-programs/user-manual/*.lua", false, true)
		table.sort(files)
		for _, file in ipairs(files) do
			BY_SESSION[#BY_SESSION + 1] = { session = vim.fn.fnamemodify(file, ":t:r"), sets = dofile(file) }
		end
	end

	it("there are sessions to check at all", function()
		eq(true, #BY_SESSION > 0)
	end)

	for _, s in ipairs(BY_SESSION) do
		for _, entry in ipairs(emit_mod.uncreditable(s.sets)) do
			it(("%s %s  %s is credited as %s"):format(s.session, entry.set_id, entry.exercise, entry.credited), function()
				eq(entry.exercise, entry.credited)
			end)
		end
	end
end)

-- =========================================================================
-- Negative rule triggers, across every shipped session
-- =========================================================================

--- Every negative-rule trigger in every session this repo ships, examples included:
--- the example sessions are where the rules live, and a trigger that names an action
--- nothing emits fails exactly as quietly as a dead exercise -- the rule simply never
--- fires. Arrow triggers were in that state until track-action decoded K_SPECIAL.
---
--- **Whether each one can fire is checked in track-action's
--- `tests/vocabulary_spec.lua`**, for the same reason the key exercises are: a
--- trigger is an action string, and asking what produces one means typing keys into
--- a Neovim this one cannot be. What is left here is the half that is about *this*
--- repo's content rather than about Neovim: that the rules parse into triggers at
--- all, through the engine's own parser rather than a second copy of it.
---@return table[] { session, set_id, trigger, action }
local function shipped_triggers()
	local out = {}
	local files = vim.fn.glob(vim.fn.getcwd() .. "/exercise-programs/**/*.lua", false, true)
	table.sort(files)
	local parse_trigger = require("coach.tracker")._parse_trigger
	for _, file in ipairs(files) do
		local session = vim.fn.fnamemodify(file, ":t:r")
		for _, set in ipairs(dofile(file)) do
			for _, rule in ipairs(set.negatives or {}) do
				for _, trigger in ipairs(rule.triggers or {}) do
					local action = parse_trigger(trigger)
					out[#out + 1] = { session = session, set_id = set.id, trigger = trigger, action = action }
				end
			end
		end
	end
	return out
end

describe("every shipped negative trigger is well-formed", function()
	local TRIGGERS = shipped_triggers()

	it("there are triggers to check at all", function()
		eq(true, #TRIGGERS > 0, "no negative rules found under exercise-programs/")
	end)

	it("names where the can-it-fire check lives", function()
		print(("      %d trigger(s) parsed; whether each can fire is fenced in track-action's tests/vocabulary_spec.lua"):format(#TRIGGERS))
		eq(true, true)
	end)

	for _, t in ipairs(TRIGGERS) do
		it(("%s %s  %s parses to an action"):format(t.session, t.set_id, t.trigger), function()
			-- The `[N]` consecutive-press prefix is stripped through the engine's own
			-- parser, so this cannot disagree with what the engine matches on. An
			-- empty result means the trigger is punctuation the rule can never match.
			eq("string", type(t.action))
			eq(true, #t.action > 0, "trigger parsed to an empty action")
		end)
	end
end)

h.summary()
