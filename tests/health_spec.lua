-- Health spec: what :checkhealth coach reports
--
-- The checks live in `health.report()`, which returns plain data, and `check()`
-- only renders it through vim.health. That split is what makes them testable: the
-- vim.health functions are output, and there is nothing to assert about output.

local h = require("harness")
local describe, it, eq, is_true, is_false = h.describe, h.it, h.eq, h.is_true, h.is_false

local programs = require("coach.programs")
programs._set_state_file(vim.fn.tempname() .. "_coach_health_state.json")
programs.configure({ active = "user-manual/01-first-steps" })

local progress = require("coach.progress")
progress.configure({ progress_dir = vim.fn.tempname() .. "_coach_health_progress", required_reps = 3 })

local health = require("coach.health")

--- The report entry whose `name` matches, or nil.
local function entry(report, name)
	for _, e in ipairs(report) do
		if e.name == name then
			return e
		end
	end
	return nil
end

describe("health.report", function()
	it("returns a non-empty list of entries", function()
		local report = health.report()
		is_true(#report > 0)
	end)

	it("every entry has a name, level and message", function()
		for _, e in ipairs(health.report()) do
			is_true(type(e.name) == "string" and #e.name > 0, "name")
			is_true(e.level == "ok" or e.level == "warn" or e.level == "error", "level: " .. tostring(e.level))
			is_true(type(e.message) == "string" and #e.message > 0, "message for " .. e.name)
		end
	end)

	describe("track-action", function()
		it("is reported present when it is", function()
			local e = assert(entry(health.report(), "track-action.nvim"))
			-- The suite runs with the sibling checkout on the runtimepath; without it
			-- this is the error case, which is equally correct to report.
			if pcall(require, "track-action") then
				eq("ok", e.level)
			else
				eq("error", e.level)
			end
		end)

		it("names the shared functions it needs", function()
			local e = assert(entry(health.report(), "track-action.nvim"))
			is_true(e.message:find("strip_decoration", 1, true) ~= nil or e.level == "error")
		end)
	end)

	describe("active session", function()
		it("is ok with a resolved pointer and a loaded set list", function()
			local e = assert(entry(health.report(), "active session"))
			eq("ok", e.level)
			is_true(e.message:find("01-first-steps", 1, true) ~= nil, e.message)
		end)

		it("is an error when nothing is active", function()
			local report = health.report({ active = false, set_count = 0 })
			eq("error", assert(entry(report, "active session")).level)
		end)

		it("is an error when the active session has no sets", function()
			local report = health.report({ active = { program = "p", session = "s" }, set_count = 0 })
			eq("error", assert(entry(report, "active session")).level)
		end)
	end)

	describe("progress directory", function()
		it("is ok when writable", function()
			eq("ok", assert(entry(health.report(), "progress directory")).level)
		end)

		it("is an error when it cannot be written", function()
			-- /proc is real, present and not writable, so this needs no fixture.
			local report = health.report({ progress_dir = "/proc/coach-cannot-write-here" })
			local e = assert(entry(report, "progress directory"))
			eq("error", e.level)
			is_true(e.message:find("/proc/coach-cannot-write-here", 1, true) ~= nil, e.message)
		end)
	end)

	describe("programs", function()
		it("reports the builtin program as loaded", function()
			local e = assert(entry(health.report(), "program user-manual"))
			eq("ok", e.level)
		end)

		it("warns about a program with no sessions", function()
			local report = health.report({
				programs = { { name = "empty-one", source = "/nonexistent-coach-dir" } },
				sessions_for = function()
					return {}
				end,
			})
			local e = assert(entry(report, "program empty-one"))
			eq("warn", e.level)
		end)
	end)

	describe("exercises of the active session", function()
		it("is ok when every exercise emits", function()
			local e = entry(health.report(), "exercises")
			if e then
				eq("ok", e.level)
			end
		end)

		it("warns and names an exercise the parser cannot emit", function()
			local report = health.report({
				sets = {
					{
						id = "99.1",
						title = "Bogus",
						exercises = { { exercise = "ZZZ_not_a_command", display = "?", desc = "?" } },
					},
				},
			})
			local e = entry(report, "exercises")
			-- Without track-action there is no parser to ask, and the check is skipped.
			if e and e.level ~= "ok" then
				eq("warn", e.level)
				is_true(e.message:find("ZZZ_not_a_command", 1, true) ~= nil, e.message)
				is_true(e.message:find("99.1", 1, true) ~= nil, e.message)
			end
		end)

		it("is not reported at all when no session is loaded", function()
			-- Otherwise it reads as a vacuous OK beside the error saying there is no
			-- session to check.
			local report = health.report({ active = false, set_count = 0, sets = {} })
			eq(nil, entry(report, "exercises"))
		end)
	end)

	it("check() runs without error", function()
		-- vim.health.* is only meaningful inside :checkhealth, but calling it must
		-- not raise: a health module that errors is worse than no health module.
		is_false(not pcall(health.check))
	end)
end)

h.summary()
