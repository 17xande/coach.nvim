local h = require("harness")
local describe, it, eq, is_true, is_false, is_nil =
	h.describe, h.it, h.eq, h.is_true, h.is_false, h.is_nil

--- Stub track-action so tracker.start() succeeds headlessly.
package.loaded["track-action"] = {
	on_key_action = function() end,
	on_cmd_action = function() end,
	off_key_action = function() end,
	off_cmd_action = function() end,
}

local root = vim.fn.tempname() .. "_coach_reset"

--- Build a fully wired coach with its own progress dir. Returns the modules.
local function fresh_coach()
	for _, m in ipairs({
		"coach",
		"coach.progress",
		"coach.programs",
		"coach.sets",
		"coach.sources",
		"coach.builtin",
		"coach.tracker",
		"coach.window",
		"coach.index",
		"coach.keybinds",
		"coach.log",
	}) do
		package.loaded[m] = nil
	end

	vim.fn.delete(root, "rf")
	vim.fn.mkdir(root, "p")

	local programs = require("coach.programs")
	programs._set_state_file(root .. "/state.json")

	local coach = require("coach")
	coach.setup({ progress_dir = root .. "/progress", required_reps = 3 })

	return coach, require("coach.progress"), require("coach.programs"), require("coach.sets")
end

---@param path string
---@return string|nil
local function read_file(path)
	local f = io.open(path, "r")
	if not f then
		return nil
	end
	local c = f:read("*a")
	f:close()
	return c
end

--- read_file, but fail the test if the file is missing.
---@param path string
---@return string
local function must_read(path)
	local c = read_file(path)
	if not c then
		error("expected file to exist: " .. path, 2)
	end
	return c
end

---@param program string
---@param session string
---@return string
local function progress_path(program, session)
	return root .. "/progress/" .. program .. "/" .. session .. ".json"
end

--- The active pointer, asserted non-nil.
---@param programs table
---@return { program: string, session: string }
local function active_pointer(programs)
	local a = programs.get_active()
	if not a then
		error("expected an active program/session", 2)
	end
	return a
end

describe("reset", function()
	describe(":CoachReset (current set)", function()
		it("clears counts even when coaching is not active", function()
			local coach, progress = fresh_coach()
			is_false(coach.is_active())

			progress.increment("i")
			progress.increment("i")
			eq(2, progress.get_count("i"))

			coach.reset_set()
			eq(0, progress.get_count("i"))
		end)

		it("persists the cleared counts to disk", function()
			local coach, progress, programs = fresh_coach()
			local a = active_pointer(programs)
			progress.increment("i")
			coach.reset_set()

			local raw = must_read(progress_path(a.program, a.session))
			local data = vim.json.decode(raw)
			eq(0, (data.sets["02.2"] or {}).i or 0)
		end)
	end)

	describe(":CoachResetSession (current session)", function()
		it("clears every set and returns to set 1 when coaching is not active", function()
			local coach, progress = fresh_coach()
			progress.increment("i")
			progress.advance()
			eq(2, progress.get_set_index())

			coach.reset_session()
			eq(1, progress.get_set_index())
			eq(0, progress.get_count("i"))
		end)

		it("leaves other sessions of the program alone", function()
			local coach, progress, programs, sets = fresh_coach()
			local a = active_pointer(programs)
			local other = programs.sessions(a.program)[2].name

			coach.switch_session(a.program .. "/" .. other)
			local other_set_id = sets.get(1).id
			local ex = sets.get(1).exercises[1].exercise
			progress.increment(ex)
			progress.save()

			coach.switch_session(a.program .. "/" .. a.session)
			coach.reset_session()

			local data = vim.json.decode(must_read(progress_path(a.program, other)))
			eq(1, data.sets[other_set_id] and data.sets[other_set_id][ex] or nil)
		end)
	end)

	describe(":CoachResetProgram (whole program)", function()
		it("wipes progress for every session in the active program", function()
			local coach, progress, programs, sets = fresh_coach()
			local a = active_pointer(programs)
			local other = programs.sessions(a.program)[2].name

			coach.switch_session(a.program .. "/" .. other)
			local other_set_id = sets.get(1).id
			local ex = sets.get(1).exercises[1].exercise
			progress.increment(ex)
			progress.advance()
			progress.save()

			coach.switch_session(a.program .. "/" .. a.session)
			progress.increment("i")
			progress.save()

			coach.reset_program({ confirm = false })

			-- active session cleared in memory
			eq(1, progress.get_set_index())
			eq(0, progress.get_count("i"))

			-- the other session's file is gone (or empty)
			local raw = read_file(progress_path(a.program, other))
			if raw then
				local data = vim.json.decode(raw)
				eq(1, data.current_set_index)
				eq(0, (data.sets[other_set_id] or {})[ex] or 0)
			else
				is_nil(raw)
			end
		end)

		it("works while coaching is active", function()
			local coach, progress = fresh_coach()
			coach.start()
			is_true(coach.is_active())
			progress.increment("i")
			coach.reset_program({ confirm = false })
			eq(0, progress.get_count("i"))
			coach.stop()
		end)

		it("prompts before wiping, and keeps progress when declined", function()
			local coach, progress = fresh_coach()
			progress.increment("i")
			progress.increment("i")

			local real_confirm = vim.fn.confirm
			---@type string|nil
			local seen_prompt = nil
			---@diagnostic disable-next-line: duplicate-set-field
			vim.fn.confirm = function(prompt)
				seen_prompt = prompt
				return 2 -- "No"
			end

			local ok, err = pcall(coach.reset_program)
			vim.fn.confirm = real_confirm
			is_true(ok, "reset_program errored: " .. tostring(err))

			if not seen_prompt then
				error("expected a confirmation prompt")
			end
			is_true(
				seen_prompt:find("user-manual", 1, true) ~= nil,
				"expected the program name in the prompt, got: " .. seen_prompt
			)
			eq(2, progress.get_count("i"), "declining the prompt must not clear progress")
		end)

		it("wipes when the prompt is accepted", function()
			local coach, progress = fresh_coach()
			progress.increment("i")

			local real_confirm = vim.fn.confirm
			---@diagnostic disable-next-line: duplicate-set-field
			vim.fn.confirm = function()
				return 1 -- "Yes"
			end

			local ok = pcall(coach.reset_program)
			vim.fn.confirm = real_confirm
			is_true(ok)
			eq(0, progress.get_count("i"))
		end)

		it("defaults the prompt to No", function()
			local coach = fresh_coach()

			local real_confirm = vim.fn.confirm
			local default_choice = nil
			---@diagnostic disable-next-line: duplicate-set-field
			vim.fn.confirm = function(_, _, default)
				default_choice = default
				return 2
			end

			pcall(coach.reset_program)
			vim.fn.confirm = real_confirm
			eq(2, default_choice, "a stray <CR> must not wipe progress")
		end)
	end)

	describe("persisted json shape", function()
		it("encodes empty counts as an object, not an array", function()
			local coach, progress, programs = fresh_coach()
			local a = active_pointer(programs)
			progress.increment("i")
			coach.reset_session()

			local raw = must_read(progress_path(a.program, a.session))
			is_true(raw:find('"sets":{', 1, true) ~= nil, 'expected "sets" to be a JSON object, got: ' .. raw)
		end)

		it("encodes a cleared single set as an object, not an array", function()
			local coach, progress, programs = fresh_coach()
			local a = active_pointer(programs)
			progress.increment("i")
			coach.reset_set()

			local raw = must_read(progress_path(a.program, a.session))
			is_true(raw:find("[", 1, true) == nil, "expected no JSON arrays in: " .. raw)
		end)
	end)
end)

vim.fn.delete(root, "rf")
h.summary()
