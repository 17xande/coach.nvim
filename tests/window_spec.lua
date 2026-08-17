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
