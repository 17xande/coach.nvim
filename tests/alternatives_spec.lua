-- Alternatives spec: keybinds learned from what the user actually pressed
-- Run: nvim --headless -u tests/minimal_init.lua -c "luafile tests/alternatives_spec.lua"
--
-- If you have your own mapping for an exercise, pressing it counts -- Neovim reports
-- the command your mapping ran, so that needs no help. What needed help was *showing*
-- it in the window beside the default keys.
--
-- That used to be a static scan: read every normal-mode mapping at render time, run
-- each right-hand side through track-action's parser, and compare the action it
-- produced. It worked for `<leader>W` -> `5w` and could never work for a Lua-callback
-- mapping, whose right-hand side is not keys at all. With no parser it cannot work
-- for either.
--
-- The replacement arrives from the other direction and is strictly better: every atom
-- a mapping produces carries its `lhs`, so an alternative is **learned the first time
-- the user presses it**. A Lua callback is no harder than a `5w`, because nothing is
-- being interpreted -- the editor already told us both halves.
--
-- The cost is that a mapping is not listed until it has been used once. That is the
-- right trade: a list of every mapping that *might* be an alternative was noise, and
-- the one the user actually reaches for is the one worth showing.

package.path = "tests/?.lua;" .. package.path
local h = require("harness")
local describe, it, eq = h.describe, h.it, h.eq
local is_true = function(v, msg)
	eq(true, v, msg)
end

--- The harness's `eq` compares with `~=`, which is identity for tables. Most of the
--- assertions here are about list contents, so they need a deep compare.
local function same(expected, actual, msg)
	if not vim.deep_equal(expected, actual) then
		error(
			("%s: expected %s, got %s"):format(msg or "lists differ", vim.inspect(expected), vim.inspect(actual)),
			2
		)
	end
end

local alternatives = require("coach.alternatives")

--- A scratch file per case, so nothing reads or writes the user's real one.
local function scratch()
	return vim.fn.tempname() .. "-coach-alternatives.json"
end

describe("learning", function()
	it("records the keys pressed for an exercise", function()
		alternatives.setup({ path = scratch() })
		alternatives.learn("[count]w", "<leader>W")
		same({ "<leader>W" }, alternatives.for_exercise("[count]w"))
	end)

	it("keeps more than one mapping for the same exercise", function()
		alternatives.setup({ path = scratch() })
		alternatives.learn("[count]w", "<leader>W")
		alternatives.learn("[count]w", ",m")
		eq(2, #alternatives.for_exercise("[count]w"))
	end)

	it("records a mapping once however often it is pressed", function()
		alternatives.setup({ path = scratch() })
		for _ = 1, 5 do
			alternatives.learn("[count]w", "<leader>W")
		end
		eq(1, #alternatives.for_exercise("[count]w"))
	end)

	it("returns them in a stable order", function()
		-- The window puts these in a line, and a line that reorders itself between
		-- renders reads as though something changed.
		alternatives.setup({ path = scratch() })
		alternatives.learn("w", "zz")
		alternatives.learn("w", "aa")
		alternatives.learn("w", "mm")
		same({ "aa", "mm", "zz" }, alternatives.for_exercise("w"))
	end)

	it("ignores the exercise's own keys", function()
		-- Pressing `w` reports no lhs at all, but a mapping of `w` to something that
		-- still performs `w` does -- and listing `w` as an alternative for `w` is
		-- noise, not information.
		alternatives.setup({ path = scratch() })
		alternatives.learn("w", "w")
		same({}, alternatives.for_exercise("w"))
	end)

	it("ignores a decorated exercise's own keys too", function()
		-- `[count]w` is pressed as `3w`, and `f{char}` as `fa`; the bare keys are what
		-- a mapping would have to differ from. Uses track-action's own
		-- `strip_decoration`, so this cannot disagree with shadow detection.
		alternatives.setup({ path = scratch() })
		alternatives.learn("[count]w", "w")
		alternatives.learn("f{char}", "f")
		same({}, alternatives.for_exercise("[count]w"))
		same({}, alternatives.for_exercise("f{char}"))
	end)

	it("ignores an empty or absent lhs", function()
		alternatives.setup({ path = scratch() })
		alternatives.learn("w", "")
		alternatives.learn("w", nil)
		same({}, alternatives.for_exercise("w"))
	end)

	it("returns an empty list for an exercise with none", function()
		alternatives.setup({ path = scratch() })
		same({}, alternatives.for_exercise("dw"))
		same({}, alternatives.for_exercise(nil))
	end)
end)

describe("persistence", function()
	it("survives a reload", function()
		local path = scratch()
		alternatives.setup({ path = path })
		alternatives.learn("[count]w", "<leader>W")
		alternatives.flush()

		alternatives.setup({ path = path })
		same({ "<leader>W" }, alternatives.for_exercise("[count]w"))
	end)

	it("starts empty when there is no file", function()
		alternatives.setup({ path = scratch() })
		same({}, alternatives.for_exercise("w"))
	end)

	it("starts empty rather than erroring on an unreadable file", function()
		local path = scratch()
		local f = assert(io.open(path, "w"))
		f:write("{ not json")
		f:close()
		alternatives.setup({ path = path })
		same({}, alternatives.for_exercise("w"))
	end)

	it("discards a file from another version rather than migrating it", function()
		-- House rule: version the file and throw the old one away. What an action
		-- string *means* is what changes, and inventing a mapping between two
		-- spellings is more machinery than a re-learn is worth -- and a re-learn here
		-- costs one keypress.
		local path = scratch()
		local f = assert(io.open(path, "w"))
		f:write(vim.json.encode({ version = 0, alternatives = { w = { "zz" } } }))
		f:close()
		alternatives.setup({ path = path })
		same({}, alternatives.for_exercise("w"))
	end)

	it("writes the current version", function()
		local path = scratch()
		alternatives.setup({ path = path })
		alternatives.learn("w", "zz")
		alternatives.flush()

		local f = assert(io.open(path, "r"))
		local data = vim.json.decode(f:read("*a"))
		f:close()
		eq(alternatives.CURRENT_VERSION, data.version)
		same({ "zz" }, data.alternatives.w)
	end)

	it("does not write a file it has nothing to say", function()
		-- Otherwise every startup creates one, which makes "has this user ever mapped
		-- anything" unanswerable from the filesystem.
		local path = scratch()
		alternatives.setup({ path = path })
		alternatives.flush()
		eq(0, vim.fn.filereadable(path))
	end)

	it("debounces rather than writing on every press", function()
		-- A rep is a keystroke. Same reasoning as progress.schedule_save: writing per
		-- keystroke is too much, and `flush` is what forces it.
		local path = scratch()
		alternatives.setup({ path = path })
		alternatives.learn("w", "zz")
		eq(0, vim.fn.filereadable(path), "not written yet")
		alternatives.flush()
		eq(1, vim.fn.filereadable(path))
	end)
end)

describe("the set-level accessor the window uses", function()
	it("maps each exercise to its learned keys", function()
		alternatives.setup({ path = scratch() })
		alternatives.learn("w", "zz")
		alternatives.learn("dw", "qq")
		local got = alternatives.get({
			exercises = {
				{ exercise = "w", display = "w", desc = "Word" },
				{ exercise = "dw", display = "dw", desc = "Delete word" },
				{ exercise = "b", display = "b", desc = "Back" },
			},
		})
		same({ "zz" }, got.w)
		same({ "qq" }, got.dw)
		eq(nil, got.b, "an exercise with none should be absent, not an empty list")
	end)

	it("survives a set with no exercises", function()
		alternatives.setup({ path = scratch() })
		same({}, alternatives.get({}))
		same({}, alternatives.get(nil))
	end)
end)

describe("clearing", function()
	it("forgets everything, and says so on disk", function()
		local path = scratch()
		alternatives.setup({ path = path })
		alternatives.learn("w", "zz")
		alternatives.flush()
		is_true(vim.fn.filereadable(path) == 1)

		alternatives.clear()
		same({}, alternatives.for_exercise("w"))
		alternatives.flush()
		local f = assert(io.open(path, "r"))
		local data = vim.json.decode(f:read("*a"))
		f:close()
		eq(0, vim.tbl_count(data.alternatives))
	end)
end)

h.summary()
