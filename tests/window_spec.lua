local h = require("harness")
local describe, it, eq, is_true, is_false = h.describe, h.it, h.eq, h.is_true, h.is_false

local window = require("coach.window")

local sample_set = {
	id = "02.3",
	title = "Moving Around",
	help_tag = "02.3",
	exercises = {
		{ exercise = "h", display = "h", desc = "Move left" },
		{ exercise = "j", display = "j", desc = "Move down" },
	},
}

local sample_set_no_help = {
	id = "99.1",
	title = "No Help Tag",
	exercises = {
		{ exercise = "x", display = "x", desc = "Test" },
	},
}

describe("window", function()
	describe("open and close", function()
		it("is not open initially", function()
			is_false(window.is_open())
		end)

		it("opens a floating window", function()
			window.open()
			is_true(window.is_open())
			window.close()
		end)

		it("close makes it not open", function()
			window.open()
			is_true(window.is_open())
			window.close()
			is_false(window.is_open())
		end)

		it("double open is safe", function()
			window.open()
			window.open()
			is_true(window.is_open())
			window.close()
		end)

		it("double close is safe", function()
			window.close()
			window.close()
			is_false(window.is_open())
		end)
	end)

	describe("toggle", function()
		it("opens when closed", function()
			window.close()
			local opened = window.toggle()
			is_true(opened)
			is_true(window.is_open())
			window.close()
		end)

		it("closes when open", function()
			window.open()
			local opened = window.toggle()
			is_false(opened)
			is_false(window.is_open())
		end)
	end)

	describe("render", function()
		it("renders without error on empty counts", function()
			window.open()
			window.render(sample_set, {}, 20, "<leader>kn")
			is_true(window.is_open())
			window.close()
		end)

		it("renders with partial counts", function()
			window.open()
			window.render(sample_set, { h = 5, j = 10 }, 20, "<leader>kn")
			is_true(window.is_open())
			window.close()
		end)

		it("renders completed exercise", function()
			window.open()
			window.render(sample_set, { h = 20, j = 20 }, 20, "<leader>kn")
			is_true(window.is_open())
			window.close()
		end)

		it("renders exercise without help_tag", function()
			window.open()
			window.render(sample_set_no_help, {}, 20, "<leader>kn")
			is_true(window.is_open())
			window.close()
		end)

		it("does not crash when window is closed", function()
			window.close()
			-- should silently do nothing
			window.render(sample_set, {}, 20, "<leader>kn")
			is_false(window.is_open())
		end)

		it("renders counts clamped to required_reps", function()
			window.open()
			-- count exceeds required_reps, should not crash
			window.render(sample_set, { h = 999, j = 999 }, 20, "<leader>kn")
			is_true(window.is_open())
			window.close()
		end)
	end)

	describe("render with shadowed actions", function()
		it("renders shadowed action without crash", function()
			window.open()
			local shadowed = { ["h"] = "Prev Buffer" }
			window.render(sample_set, {}, 20, "<leader>kn", shadowed)
			is_true(window.is_open())
			window.close()
		end)

		it("renders all-shadowed exercise (vacuously complete)", function()
			window.open()
			local shadowed = { ["h"] = true, ["j"] = true }
			window.render(sample_set, {}, 20, "<leader>kn", shadowed)
			is_true(window.is_open())
			window.close()
		end)

		it("renders mix of shadowed and normal actions", function()
			window.open()
			local shadowed = { ["h"] = "Mapped away" }
			window.render(sample_set, { j = 10 }, 20, "<leader>kn", shadowed)
			is_true(window.is_open())
			window.close()
		end)

		it("empty shadowed table behaves like no shadowed", function()
			window.open()
			window.render(sample_set, { h = 5, j = 10 }, 20, "<leader>kn", {})
			is_true(window.is_open())
			window.close()
		end)
	end)

	describe("render with alternatives", function()
		it("renders with alternatives without crash", function()
			window.open()
			local alts = { ["h"] = { "Ctrl-H" } }
			window.render(sample_set, { h = 5 }, 20, "<leader>kn", {}, alts)
			is_true(window.is_open())
			window.close()
		end)

		it("renders with empty alternatives table", function()
			window.open()
			window.render(sample_set, {}, 20, "<leader>kn", {}, {})
			is_true(window.is_open())
			window.close()
		end)

		it("renders with both shadowed and alternatives", function()
			window.open()
			local shadowed = { ["h"] = true }
			local alts = { ["j"] = { "Ctrl-J" } }
			window.render(sample_set, { j = 5 }, 20, "<leader>kn", shadowed, alts)
			is_true(window.is_open())
			window.close()
		end)
	end)

	describe("set_message", function()
		it("does not crash", function()
			window.open()
			window.set_message("Test message")
			window.render(sample_set, {}, 20, "<leader>kn")
			is_true(window.is_open())
			window.close()
		end)
	end)

	describe("render_welcome", function()
		it("does not crash", function()
			window.open()
			window.render_welcome("<leader>kn")
			is_true(window.is_open())
			window.close()
		end)
		it("does not crash when window is closed", function()
			window.close()
			window.render_welcome("<leader>kn")
			is_false(window.is_open())
		end)
	end)
end)

-- =========================================================================
-- Column alignment is a display-width question, not a byte-count one
-- =========================================================================
--
-- The columns were padded with `#str`, which counts bytes. A description with a
-- typographic dash or any other multi-byte character is shorter on screen than in
-- bytes, so its row's progress bar sat left of everyone else's.

describe("column alignment", function()
	--- Rendered lines of the float.
	local function lines()
		return vim.api.nvim_buf_get_lines(assert(window._buf()), 0, -1, false)
	end

	--- Which screen column the progress bar starts at on the line containing `needle`.
	---@return number|nil
	local function bar_column(needle)
		for _, line in ipairs(lines()) do
			if line:find(needle, 1, true) then
				local byte_index = line:find("\u{2588}", 1, true) or line:find("\u{2591}", 1, true)
				if byte_index then
					return vim.fn.strdisplaywidth(line:sub(1, byte_index - 1))
				end
			end
		end
		return nil
	end

	local multibyte_set = {
		id = "01.1",
		title = "Alignment",
		exercises = {
			{ exercise = "a", display = "a", desc = "plain ascii" },
			{ exercise = "b", display = "b", desc = "em\u{2014}dash \u{2014} here" },
			{ exercise = "c", display = "c", desc = "ascii again" },
		},
	}

	it("puts every progress bar in the same screen column", function()
		window.open()
		window.render(multibyte_set, { a = 1, b = 1, c = 1 }, 10, "<leader>kn")

		local ascii = bar_column("plain ascii")
		local wide = bar_column("dash")
		local ascii2 = bar_column("ascii again")
		is_true(ascii ~= nil, "found the ascii row's bar")
		eq(ascii, wide, "multibyte row's bar column")
		eq(ascii, ascii2, "second ascii row's bar column")
		window.close()
	end)
end)

-- =========================================================================
-- Window geometry
-- =========================================================================

describe("geometry", function()
	local function config_of()
		return vim.api.nvim_win_get_config(assert(window._win()))
	end

	it("defaults to 34x8 in the top right", function()
		window.configure({})
		window.close()
		window.open()
		local cfg = config_of()
		eq(34, cfg.width)
		eq(8, cfg.height)
		eq(1, cfg.row)
		eq(vim.o.columns - 34 - 2, cfg.col)
		window.close()
	end)

	it("takes a configured width and height", function()
		window.configure({ width = 50, height = 12 })
		window.close()
		window.open()
		local cfg = config_of()
		eq(50, cfg.width)
		eq(12, cfg.height)
		window.close()
	end)

	it("puts the window bottom-left when asked", function()
		window.configure({ width = 20, height = 5, position = "bottom-left" })
		window.close()
		window.open()
		local cfg = config_of()
		eq(2, cfg.col)
		eq(vim.o.lines - 5 - 4, cfg.row)
		window.close()
	end)

	it("an explicit row and col win over the position", function()
		window.configure({ width = 20, height = 5, position = "top-right", row = 7, col = 3 })
		window.close()
		window.open()
		local cfg = config_of()
		eq(7, cfg.row)
		eq(3, cfg.col)
		window.close()
	end)

	it("ignores an unknown position rather than erroring", function()
		window.configure({ position = "sideways" })
		window.close()
		window.open()
		is_true(window.is_open())
		window.close()
		window.configure({})
	end)
end)

-- =========================================================================
-- The message timer's libuv handle
-- =========================================================================
--
-- A timer is a handle, not garbage: dropping the reference without :close()
-- leaves it registered with the event loop for the life of the session, and the
-- anti-spam message sets one every time it fires. Counting handles is the only
-- way to see it -- the module local looks the same either way.

local uv = vim.uv or vim.loop

local function count_timers()
	local n = 0
	uv.walk(function(handle)
		if handle:get_type() == "timer" and not handle:is_closing() then
			n = n + 1
		end
	end)
	return n
end

describe("message timer", function()
	it("uses one handle however many messages are set", function()
		window.set_message("first")
		local base = count_timers()
		for i = 1, 20 do
			window.set_message("message " .. i)
		end
		eq(base, count_timers(), "timer handles after 20 more messages")
	end)

	it("still has one handle after the message expires", function()
		window.set_message("expiring")
		local base = count_timers()
		-- Fire the timeout by hand rather than waiting 2s for it.
		window._expire_message()
		window.set_message("next one")
		eq(base, count_timers(), "timer handles after a message expired")
	end)

	it("clears the message when it expires", function()
		window.set_message("expiring")
		window._expire_message()
		eq(nil, window._pending_message())
	end)

	it("closes the handle on stop", function()
		window.stop_message() -- start from a known state: no handle held
		local base = count_timers()
		window.set_message("hello")
		window.stop_message()
		eq(base, count_timers(), "timer handles after stop_message")
	end)

	it("drops the pending message on stop", function()
		window.set_message("hello")
		window.stop_message()
		eq(nil, window._pending_message())
	end)
end)

h.summary()
