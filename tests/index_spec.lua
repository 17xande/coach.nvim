local h = require("harness")
local describe, it, is_true, is_false = h.describe, h.it, h.is_true, h.is_false

local programs = require("coach.programs")
programs._set_state_file(vim.fn.tempname() .. "_coach_idx_state.json")
programs.configure({ active = "user-manual/01-first-steps" })

local progress = require("coach.progress")
progress.configure({ progress_file = vim.fn.tempname() .. "_coach_idx_test.json", required_reps = 3 })
progress.load()

local index = require("coach.index")

describe("index", function()
	it("is not open initially", function()
		is_false(index.is_open())
	end)

	it("opens a window", function()
		index.open(nil)
		is_true(index.is_open())
		index.close()
	end)

	it("close makes it not open", function()
		index.open(nil)
		index.close()
		is_false(index.is_open())
	end)

	it("double close is safe", function()
		index.close()
		index.close()
		is_false(index.is_open())
	end)

	it("toggle opens when closed", function()
		index.close()
		index.toggle(nil)
		is_true(index.is_open())
		index.close()
	end)

	it("toggle closes when open", function()
		index.open(nil)
		index.toggle(nil)
		is_false(index.is_open())
	end)
end)

-- =========================================================================
-- refresh
-- =========================================================================
--
-- The sidebar was rendered once, at open. Reps counted while it was up -- and
-- resets performed while it was up -- left it showing the state it had when it
-- opened.

describe("index.refresh", function()
	local sets = require("coach.sets")

	--- The sidebar's current contents, as one string.
	local function contents()
		local lines = vim.api.nvim_buf_get_lines(assert(index._buf()), 0, -1, false)
		return table.concat(lines, "\n")
	end

	--- Fill every exercise of set 2 to its required reps, then park the cursor on
	--- set 1: the current set always renders as ▶, so a completed set only shows ✓
	--- while it is not the current one.
	local function complete_set_two()
		progress.go_to(2)
		local s = assert(sets.get(2))
		local reps = s.required_reps or progress.get_required_reps()
		for _, ex in ipairs(s.exercises) do
			for _ = 1, reps do
				progress.increment(ex.exercise)
			end
		end
		progress.go_to(1)
	end

	it("is safe to call when the sidebar is closed", function()
		index.close()
		index.refresh() -- must not error
		is_false(index.is_open())
	end)

	it("shows progress counted while the sidebar was open", function()
		progress.reset_session()
		index.open(nil)
		local before = contents()

		complete_set_two()
		index.refresh()

		is_true(contents() ~= before, "sidebar contents changed after progress")
		is_true(contents():find("\u{2713}", 1, true) ~= nil, "a completed set is marked done")
		index.close()
		progress.reset_session()
	end)

	it("shows a reset performed while the sidebar was open", function()
		progress.reset_session()
		complete_set_two()

		index.open(nil)
		is_true(contents():find("\u{2713}", 1, true) ~= nil, "starts out marked done")

		progress.reset_session()
		index.refresh()
		is_true(contents():find("\u{2713}", 1, true) == nil, "no longer marked done")
		index.close()
	end)
end)

h.summary()
