-- Emit spec: can every builtin exercise actually be completed?
-- Run: nvim --headless -u tests/minimal_init.lua -c "luafile tests/emit_spec.lua"
--
-- An exercise is a target for an action string that track-action.nvim emits. If it
-- targets a string the parser never produces, the row can never fill: the user
-- presses the key, nothing is credited, and the set blocks `:CoachNext` forever.
--
-- That is not hypothetical. An audit found **82 of 320 builtin exercises** in this
-- state -- 42% of the drill content -- across six clusters, every one of them a gap
-- in track-action's command tables rather than a typo here. This spec is the fence
-- that would have caught all of them: it feeds each exercise through the real
-- parser and fails on any that cannot be emitted.
--
-- It needs track-action.nvim on the runtimepath and skips itself without it, so the
-- suite still runs for someone who has only this plugin checked out.

local h = require("harness")
local describe, it, eq = h.describe, h.it, h.eq

-- track-action is a runtime dependency but not a test-harness one, so find it if it
-- is not already on the runtimepath: a sibling checkout is where it lives during
-- development. Skip the whole spec if there is none, rather than fail a suite run
-- for someone who has only this plugin.
local ok_parser, parser_mod = pcall(require, "track-action.parser")
if not ok_parser then
	local sibling = vim.fn.fnamemodify(vim.fn.getcwd(), ":h") .. "/track-action.nvim"
	if vim.fn.isdirectory(sibling) == 1 then
		vim.opt.runtimepath:append(sibling)
		ok_parser, parser_mod = pcall(require, "track-action.parser")
	end
end
if not ok_parser then
	print("emit_spec: track-action.nvim not found, skipping")
	h.summary()
	return
end
require("track-action.config").setup({ debug = false })

-- The keystroke-splitting and the parser call live in `coach.emit`, because
-- `:checkhealth coach` asks the same question at runtime and two implementations of
-- "what does this exercise emit" would eventually disagree. What this spec owns is
-- the *content* check below.
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
	for _, e in ipairs(EXERCISES) do
		-- `ex:` exercises come from the CmdlineLeave path, not the parser.
		if not e.exercise:match("^ex:") then
			local label = ("%s %s  %s"):format(e.session, e.set_id, e.exercise)
			it(label, function()
				eq(e.exercise, emitted_for(e.exercise))
			end)
		end
	end
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

h.summary()
