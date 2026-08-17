local h = require("harness")
local describe, it, eq, is_true, is_false = h.describe, h.it, h.eq, h.is_true, h.is_false

local function fresh()
	package.loaded["coach.sets"] = nil
	package.loaded["coach.programs"] = nil
	package.loaded["coach.sources"] = nil
	package.loaded["coach.builtin"] = nil
	local programs = require("coach.programs")
	programs._set_state_file(vim.fn.tempname() .. "_coach_programs_state.json")
	return programs
end

--- Build a temp session directory.
---@return string dir
local function make_dir(sessions)
	local dir = vim.fn.tempname() .. "_coach_sessions"
	vim.fn.mkdir(dir, "p")
	for name, body in pairs(sessions) do
		local f = assert(io.open(dir .. "/" .. name .. ".lua", "w"))
		f:write(body)
		f:close()
	end
	return dir
end

describe("programs", function()
	describe("configure", function()
		it("always includes the builtin program", function()
			local programs = fresh()
			programs.configure({})
			local names = {}
			for _, p in ipairs(programs.list()) do
				table.insert(names, p.name)
			end
			eq("user-manual", names[1])
		end)

		it("picks the first session of the first program by default", function()
			local programs = fresh()
			programs.configure({})
			local active = programs.get_active()
			is_true(active ~= nil)
			if not active then
				return
			end
			eq("user-manual", active.program)
			eq("01-first-steps", active.session)
		end)

		it("honors active option as program/session", function()
			local programs = fresh()
			programs.configure({ active = "user-manual/02-moving-around" })
			local active = programs.get_active()
			if not active then
				error("no active")
			end
			eq("02-moving-around", active.session)
		end)

		it("swaps sets.list on activation", function()
			local programs = fresh()
			local sets = require("coach.sets")
			eq(0, #sets.list)
			programs.configure({ active = "user-manual/02-moving-around" })
			is_true(#sets.list > 0)
			eq("03.1", sets.list[1].id)
		end)

		it("loads a local-dir program", function()
			local dir = make_dir({
				["01-foo"] = "return { { id='f.1', title='F', exercises={ { exercise='w', display='w', desc='d' } } } }",
				["02-bar"] = "return { { id='b.1', title='B', exercises={ { exercise='e', display='e', desc='d' } } } }",
			})
			local programs = fresh()
			programs.configure({ programs = { { name = "custom", source = dir } } })
			local sessions = programs.sessions("custom")
			eq(2, #sessions)
			eq("01-foo", sessions[1].name)
		end)
	end)

	describe("switch", function()
		it("changes the active session and sets.list", function()
			local programs = fresh()
			local sets = require("coach.sets")
			programs.configure({})

			local ok, err = programs.switch("user-manual", "02-moving-around")
			is_true(ok, err)
			eq("02-moving-around", programs.get_active().session)
			eq("03.1", sets.list[1].id)
		end)

		it("defaults to the first session if name omitted", function()
			local programs = fresh()
			programs.configure({})
			programs.switch("user-manual", "02-moving-around")
			local ok = programs.switch("user-manual", nil)
			is_true(ok)
			eq("01-first-steps", programs.get_active().session)
		end)

		it("returns an error for unknown program", function()
			local programs = fresh()
			programs.configure({})
			local ok, err = programs.switch("nope", nil)
			is_false(ok)
			is_true(type(err) == "string")
		end)

		it("returns an error for unknown session", function()
			local programs = fresh()
			programs.configure({})
			local ok, err = programs.switch("user-manual", "does-not-exist")
			is_false(ok)
			is_true(type(err) == "string")
		end)

		it("fires the _on_switch hook", function()
			local programs = fresh()
			programs.configure({})
			local fired = nil
			programs._on_switch = function(p, s)
				fired = p .. "/" .. s
			end
			programs.switch("user-manual", "02-moving-around")
			eq("user-manual/02-moving-around", fired)
		end)
	end)

	describe("all_session_pairs", function()
		it("lists pairs across programs", function()
			local programs = fresh()
			programs.configure({})
			local pairs_list = programs.all_session_pairs()
			is_true(#pairs_list > 1)
			-- first pair should be the first builtin session
			eq("user-manual", pairs_list[1].program)
			eq("01-first-steps", pairs_list[1].session)
		end)
	end)

	describe("active persistence", function()
		it("saved state is reloaded on next configure", function()
			local state_file = vim.fn.tempname() .. "_coach_persist.json"

			package.loaded["coach.sets"] = nil
			package.loaded["coach.programs"] = nil
			package.loaded["coach.sources"] = nil
			package.loaded["coach.builtin"] = nil
			local programs1 = require("coach.programs")
			programs1._set_state_file(state_file)
			programs1.configure({})
			programs1.switch("user-manual", "03-making-changes")

			package.loaded["coach.sets"] = nil
			package.loaded["coach.programs"] = nil
			package.loaded["coach.sources"] = nil
			package.loaded["coach.builtin"] = nil
			local programs2 = require("coach.programs")
			programs2._set_state_file(state_file)
			programs2.configure({})
			eq("03-making-changes", programs2.get_active().session)
		end)
	end)

	-- The welcome screen is shown once per *user*, so the flag belongs next to the
	-- active pointer in state.json. It used to live in each session's progress
	-- file, which meant the welcome screen came back on every new session.
	describe("welcome flag", function()
		local function with_state_file(path)
			for _, mod in ipairs({ "coach.sets", "coach.programs", "coach.sources", "coach.builtin" }) do
				package.loaded[mod] = nil
			end
			local programs = require("coach.programs")
			programs._set_state_file(path)
			return programs
		end

		it("is pending on a fresh start", function()
			local programs = with_state_file(vim.fn.tempname() .. "_coach_welcome.json")
			programs.configure({})
			is_true(programs.is_welcome_pending())
		end)

		it("stops being pending once marked", function()
			local programs = with_state_file(vim.fn.tempname() .. "_coach_welcome.json")
			programs.configure({})
			programs.mark_welcome_shown()
			is_false(programs.is_welcome_pending())
		end)

		it("persists across a restart", function()
			local path = vim.fn.tempname() .. "_coach_welcome.json"
			local programs1 = with_state_file(path)
			programs1.configure({})
			programs1.mark_welcome_shown()

			local programs2 = with_state_file(path)
			programs2.configure({})
			is_false(programs2.is_welcome_pending())
		end)

		it("does not come back when the session changes", function()
			local path = vim.fn.tempname() .. "_coach_welcome.json"
			local programs = with_state_file(path)
			programs.configure({})
			programs.mark_welcome_shown()
			programs.switch("user-manual", "03-making-changes")
			is_false(programs.is_welcome_pending())
		end)

		it("stays pending when nothing marked it", function()
			local path = vim.fn.tempname() .. "_coach_welcome.json"
			local programs1 = with_state_file(path)
			programs1.configure({})
			programs1.switch("user-manual", "03-making-changes")

			local programs2 = with_state_file(path)
			programs2.configure({})
			is_true(programs2.is_welcome_pending())
		end)

		it("survives being marked before any session resolves", function()
			local path = vim.fn.tempname() .. "_coach_welcome.json"
			local programs1 = with_state_file(path)
			programs1.mark_welcome_shown()

			local programs2 = with_state_file(path)
			programs2.configure({})
			is_false(programs2.is_welcome_pending())
		end)
	end)
end)

h.summary()
