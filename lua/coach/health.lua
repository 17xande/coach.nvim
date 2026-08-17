-- `:checkhealth coach`
--
-- The checks build a plain list of entries and `check()` only renders it, because
-- `vim.health.*` is output and there is nothing to assert about output. Everything
-- the report needs can be injected, which is how the spec reaches the failure cases
-- without breaking the user's actual setup.

local emit = require("coach.emit")
local programs = require("coach.programs")
local progress = require("coach.progress")
local sets = require("coach.sets")

local M = {}

---@class coach.HealthEntry
---@field name string Short label, also what the spec looks entries up by
---@field level "ok"|"warn"|"error"
---@field message string
---@field advice string|nil What to do about it, when there is something to do

--- Can a file be created under `dir`? Creates the directory if needed.
---@param dir string
---@return boolean ok
---@return string|nil err
local function dir_writable(dir)
	local mkdir_ok = pcall(vim.fn.mkdir, dir, "p")
	if not mkdir_ok or vim.fn.isdirectory(dir) == 0 then
		return false, "cannot create the directory"
	end

	local probe = dir .. "/.coach-health-probe"
	local f, open_err = io.open(probe, "w")
	if not f then
		return false, tostring(open_err)
	end
	f:close()
	os.remove(probe)
	return true
end

--- The shared track-action functions coach calls, and where they live.
local SHARED = {
	{ module = "track-action.commands", fn = "strip_decoration" },
	{ module = "track-action.commands", fn = "placeholder_for" },
	{ module = "track-action.mappings", fn = "native_for_ex" },
	{ module = "track-action.parser", fn = "new" },
}

--- Check track-action is installed and still exposes what coach calls.
---@return coach.HealthEntry
local function check_track_action()
	local name = "track-action.nvim"

	if not pcall(require, "track-action") then
		return {
			name = name,
			level = "error",
			message = "not installed — nothing can be tracked, so coaching will not start",
			advice = "install track-action.nvim (coach.nvim is a consumer of its API)",
		}
	end

	local missing = {}
	for _, s in ipairs(SHARED) do
		local ok, mod = pcall(require, s.module)
		if not ok or type(mod[s.fn]) ~= "function" then
			missing[#missing + 1] = s.module .. "." .. s.fn
		end
	end

	if #missing > 0 then
		return {
			name = name,
			level = "error",
			message = "installed, but missing: " .. table.concat(missing, ", "),
			advice = "update track-action.nvim; coach.nvim shares these rather than reimplementing them",
		}
	end

	return {
		name = name,
		level = "ok",
		message = "installed, with strip_decoration, placeholder_for, native_for_ex and the parser",
	}
end

--- Check something is active and its set list actually loaded.
---@param active { program: string, session: string }|nil
---@param set_count number
---@return coach.HealthEntry
local function check_active(active, set_count)
	if not active then
		return {
			name = "active session",
			level = "error",
			message = "no active session — no program resolved to one",
			advice = "check `programs` in setup(), then pick one with :CoachSession",
		}
	end

	local label = active.program .. "/" .. active.session
	if set_count == 0 then
		return {
			name = "active session",
			level = "error",
			message = label .. " is active but has no sets loaded",
			advice = "the session file may be empty or every set in it invalid; see :CoachSession",
		}
	end

	return {
		name = "active session",
		level = "ok",
		message = ("%s, %d sets"):format(label, set_count),
	}
end

--- Check each configured program resolved to at least one session.
---@param program_list coach.ProgramConfig[]
---@param sessions_for fun(name: string): table[]
---@return coach.HealthEntry[]
local function check_programs(program_list, sessions_for)
	local out = {}
	for _, p in ipairs(program_list) do
		local sessions = sessions_for(p.name) or {}
		local where = p.source and (" (" .. p.source .. ")") or " (builtin)"
		if #sessions == 0 then
			out[#out + 1] = {
				name = "program " .. p.name,
				level = "warn",
				message = "no sessions loaded" .. where,
				advice = "a local source needs .lua session files in it; a github source may still be cloning",
			}
		else
			out[#out + 1] = {
				name = "program " .. p.name,
				level = "ok",
				message = ("%d sessions%s"):format(#sessions, where),
			}
		end
	end
	return out
end

--- Check the progress directory can be written.
---@param dir string
---@return coach.HealthEntry
local function check_progress_dir(dir)
	local ok, err = dir_writable(dir)
	if not ok then
		return {
			name = "progress directory",
			level = "error",
			message = dir .. " is not writable: " .. tostring(err),
			advice = "set `progress_dir` in setup() to somewhere writable, or fix the permissions",
		}
	end
	return { name = "progress directory", level = "ok", message = dir .. " is writable" }
end

--- Check every exercise of the active session can actually be credited.
---@param sets_list table[]
---@return coach.HealthEntry|nil nil when there is no parser to ask
local function check_exercises(sets_list)
	if not emit.is_available() then
		return nil
	end

	-- With no sets loaded there is nothing to check, and "every exercise can be
	-- emitted" would be a vacuous OK next to the error that says there is no
	-- session.
	if #sets_list == 0 then
		return nil
	end

	local dead = emit.unemittable(sets_list)
	if #dead == 0 then
		return {
			name = "exercises",
			level = "ok",
			message = "every exercise in the active session can be emitted",
		}
	end

	-- Name a handful rather than all of them: the point is which ones, and a
	-- health report is read, not parsed.
	local shown = {}
	for i = 1, math.min(#dead, 5) do
		shown[#shown + 1] = ("%s %s"):format(dead[i].set_id, dead[i].exercise)
	end
	local more = #dead > #shown and (" (+%d more)"):format(#dead - #shown) or ""

	return {
		name = "exercises",
		level = "warn",
		message = ("%d exercise(s) can never be completed: %s%s"):format(
			#dead,
			table.concat(shown, ", "),
			more
		),
		advice = "these name action strings track-action does not emit; respell them (see its action format table)",
	}
end

---@class coach.HealthOverrides
---@field active? { program: string, session: string }|false `false` means none
---@field set_count? number
---@field programs? coach.ProgramConfig[]
---@field sessions_for? fun(name: string): table[]
---@field progress_dir? string
---@field sets? table[]

--- Build the report.
---
--- Every input can be overridden, which is how the spec reaches the failure paths
--- without a broken setup to reach them with.
---@param opts? coach.HealthOverrides
---@return coach.HealthEntry[]
function M.report(opts)
	opts = opts or {}

	-- `active = false` means "there is no active session", which is a case to be
	-- able to test; absent means "ask programs".
	local active
	if opts.active ~= nil then
		active = opts.active or nil
	else
		active = programs.get_active()
	end

	local sets_list = opts.sets
	if not sets_list then
		sets_list = {}
		for i = 1, sets.count() do
			sets_list[#sets_list + 1] = sets.get(i)
		end
	end

	local set_count = opts.set_count or #sets_list
	local program_list = opts.programs or programs.list()
	local sessions_for = opts.sessions_for or programs.sessions
	local progress_dir = opts.progress_dir or progress.get_progress_dir()

	local report = { check_track_action(), check_active(active, set_count) }
	vim.list_extend(report, check_programs(program_list, sessions_for))
	report[#report + 1] = check_progress_dir(progress_dir)

	local exercises = check_exercises(sets_list)
	if exercises then
		report[#report + 1] = exercises
	end

	return report
end

--- `:checkhealth coach` entry point.
function M.check()
	vim.health.start("coach.nvim")
	for _, e in ipairs(M.report()) do
		local line = e.name .. ": " .. e.message
		if e.level == "ok" then
			vim.health.ok(line)
		elseif e.level == "warn" then
			vim.health.warn(line, e.advice)
		else
			vim.health.error(line, e.advice)
		end
	end
end

return M
