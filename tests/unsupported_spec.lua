-- Unsupported spec: the exercises Neovim cannot report, and what depends on that
-- Run: nvim --headless -u tests/minimal_init.lua -c "luafile tests/unsupported_spec.lua"
--
-- Fifteen of the 333 builtin exercises can never be credited, because of deliberate
-- properties of Neovim's action model rather than anything fixable here. They are
-- labelled in the window and excluded from set completion -- **otherwise a set
-- containing one blocks `:CoachNext` forever**, which is the exact failure the emit
-- fence was built to catch.
--
-- The list itself is verified against a real Neovim in track-action's
-- `tests/vocabulary_spec.lua`, which types every exercise and asserts each of these
-- fails to render as itself. What this spec owns is the shape of the table and the
-- behaviour that keys off it.

package.path = "tests/?.lua;" .. package.path
local h = require("harness")
local describe, it, eq, is_nil = h.describe, h.it, h.eq, h.is_nil
local is_true = function(v, msg)
	eq(true, v, msg)
end

local unsupported = require("coach.unsupported")

describe("the unsupported table", function()
	it("is keyed by action string, with a reason for each", function()
		for action, reason in pairs(unsupported.ACTIONS) do
			eq("string", type(action))
			eq("string", type(reason), action .. " has no reason")
			is_true(#reason > 0, action .. " has an empty reason")
		end
	end)

	it("holds the fifteen exercises Neovim cannot report", function()
		-- A count, so adding or removing one is a deliberate edit rather than a
		-- side effect. track-action's vocabulary_spec is what proves the membership.
		eq(15, vim.tbl_count(unsupported.ACTIONS))
	end)

	it("covers every exercise the manual drills that cannot be credited", function()
		for _, action in ipairs({
			"x",
			"[count]x",
			"X",
			"s",
			"C",
			"S",
			"D",
			"do",
			"dp",
			"v",
			"V",
			"<C-v>",
			"gv",
			".",
			"!!",
		}) do
			is_true(unsupported.is(action), action .. " should be unsupported")
		end
	end)

	it("does not include <C-i>, which was renamed rather than given up on", function()
		-- Neovim names that byte `<Tab>`, which is a naming difference and not a
		-- thing it cannot report -- the user performs the jump perfectly well. The
		-- drill is spelled `<Tab>`.
		eq(false, unsupported.is("<C-i>"))
		eq(false, unsupported.is("<Tab>"))
	end)

	it("does not include the three that only a mapping's lhs can credit", function()
		-- `%`, `[count]%` and `Y` are creditable, through `data.pressed`.
		eq(false, unsupported.is("%"))
		eq(false, unsupported.is("[count]%"))
		eq(false, unsupported.is("Y"))
	end)

	it("says false for anything else", function()
		eq(false, unsupported.is("w"))
		eq(false, unsupported.is("dw"))
		eq(false, unsupported.is("ex:write"))
		eq(false, unsupported.is(nil))
		eq(false, unsupported.is(42))
	end)

	describe("the cross-crediting hazards", function()
		-- Five of the fifteen are worse than dead: where the translation is itself a
		-- drilled exercise, pressing the key credits the *other* drill. That is a
		-- silent false positive, which no label fixes -- so it is recorded here to
		-- be findable, and `credits` names the drill that actually moves.
		it("names what each hazard credits instead", function()
			eq("cc", unsupported.credits("S"))
			eq("d$", unsupported.credits("D"))
			eq("o", unsupported.credits("do"))
			eq("p", unsupported.credits("dp"))
		end)

		it("leaves the harmless translations without a credits entry", function()
			-- `x` -> `dl`, `X` -> `dh`, `s` -> `cl`, `C` -> `c$`: real translations,
			-- but those spellings are not drilled, so nothing is falsely credited.
			is_nil(unsupported.credits("x"))
			is_nil(unsupported.credits("X"))
			is_nil(unsupported.credits("s"))
			is_nil(unsupported.credits("C"))
		end)

		it("marks the dot-repeat hazard without naming one drill", function()
			-- `.` credits whatever it repeated, which is not a fixed exercise.
			is_true(unsupported.is("."))
			is_true(unsupported.ACTIONS["."]:find("repeat") ~= nil)
		end)

		it("lists every hazard's target as something the manual really drills", function()
			-- The point of the table is that these collide with *live* content. If a
			-- target stopped being drilled the hazard would be gone, and the entry
			-- with it.
			local drilled = {}
			for _, file in ipairs(vim.fn.glob(vim.fn.getcwd() .. "/exercise-programs/user-manual/*.lua", false, true)) do
				for _, set in ipairs(dofile(file)) do
					for _, e in ipairs(set.exercises or {}) do
						drilled[e.exercise] = true
					end
				end
			end
			for action in pairs(unsupported.ACTIONS) do
				local credited = unsupported.credits(action)
				if credited then
					is_true(drilled[credited], ("%s credits %s, which is not drilled"):format(action, credited))
				end
			end
		end)
	end)
end)

describe("set completion skips unsupported exercises", function()
	local progress = require("coach.progress")
	local sets = require("coach.sets")

	it("does not block on an exercise that can never be credited", function()
		-- The failure this exists to prevent: one uncreditable row in a set means
		-- `:CoachNext` refuses forever, and nothing says why.
		sets.set_active_list({
			{
				id = "99.1",
				title = "Has an unsupported row",
				exercises = {
					{ exercise = "w", display = "w", desc = "Word" },
					{ exercise = "x", display = "x", desc = "Delete char" },
				},
			},
		})
		progress.reset_session()
		progress.go_to(1)
		for _ = 1, 100 do
			progress.increment("w")
		end
		is_true(progress.is_set_complete(), "a set with an unsupported row should still complete")
	end)

	it("still blocks on a creditable exercise that is incomplete", function()
		sets.set_active_list({
			{
				id = "99.2",
				title = "Two creditable rows",
				exercises = {
					{ exercise = "w", display = "w", desc = "Word" },
					{ exercise = "b", display = "b", desc = "Back" },
				},
			},
		})
		progress.reset_session()
		progress.go_to(1)
		for _ = 1, 100 do
			progress.increment("w")
		end
		eq(false, progress.is_set_complete())
	end)
end)

h.summary()
