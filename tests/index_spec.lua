local h = require("harness")
local describe, it, is_true, is_false = h.describe, h.it, h.is_true, h.is_false

local sets = require("coach.sets")
sets._set_state_file(vim.fn.tempname() .. "_coach_idx_state.json")
sets.configure({ active = "neovim-manual/01-first-steps" })

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

h.summary()
