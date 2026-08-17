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

-- =========================================================================
-- Session titles
-- =========================================================================
--
-- A session may name itself; `sources.load` reads that title and the sidebar shows
-- it instead of the file stem. This block reconfigures programs, so it runs last.

describe("session titles in the sidebar", function()
	local dir = vim.fn.tempname() .. "_coach_titled_sessions"
	vim.fn.mkdir(dir, "p")

	local function write(name, body)
		local f = assert(io.open(dir .. "/" .. name, "w"))
		f:write(body)
		f:close()
	end

	write(
		"01-one.lua",
		"return { title = 'Chapter One', { id = '1.1', title = 'S', exercises = { { exercise = 'w', display = 'w', desc = 'd' } } } }"
	)
	write(
		"02-two.lua",
		"return { title = 'Chapter Two', { id = '2.1', title = 'S', exercises = { { exercise = 'e', display = 'e', desc = 'd' } } } }"
	)
	write(
		"03-three.lua",
		"return { { id = '3.1', title = 'S', exercises = { { exercise = 'b', display = 'b', desc = 'd' } } } }"
	)

	local function contents()
		local lines = vim.api.nvim_buf_get_lines(assert(index._buf()), 0, -1, false)
		return table.concat(lines, "\n")
	end

	programs.configure({ programs = { { name = "titled", source = dir } }, active = "titled/01-one" })
	index.open(nil)
	local rendered = contents()
	index.close()

	it("shows the active session's title", function()
		is_true(rendered:find("Chapter One", 1, true) ~= nil, rendered)
	end)

	it("shows another session's title in the other-sessions list", function()
		is_true(rendered:find("Chapter Two", 1, true) ~= nil, rendered)
	end)

	it("falls back to the file name for a session with no title", function()
		is_true(rendered:find("03-three", 1, true) ~= nil, rendered)
	end)
end)

h.summary()
