-- coach.nvim - Neovim keybinding coach
-- Public API

local sets = require("coach.sets")
local index = require("coach.index")
local keybinds = require("coach.keybinds")
local log = require("coach.log")
local progress = require("coach.progress")
local programs = require("coach.programs")
local sources = require("coach.sources")
local window = require("coach.window")
local tracker = require("coach.tracker")

local M = {}

---@type boolean
local active = false

---@type boolean
local welcome_active = false

---@type number|nil
local save_autocmd = nil

---@type string
local next_key = "<leader>kn"

--- Render the current set in the window
local function render_current()
	local s = sets.get(progress.get_set_index())
	if s then
		local shadowed = keybinds.get_shadowed(s)
		local alternatives = keybinds.get_alternatives(s)
		local reps = s.required_reps or progress.get_required_reps()
		window.render(s, progress.get_counts(), reps, next_key, shadowed, alternatives)
	end
end

window._rerender = render_current

--- Start coaching
function M.start()
	if active then
		return
	end

	progress.load()
	tracker.start()
	if progress.is_window_visible() then
		window.open()
		if progress.is_welcome_pending() then
			welcome_active = true
			vim.schedule(function()
				window.render_welcome(next_key)
			end)
		else
			vim.schedule(render_current)
			-- Re-render once more after lazy-loaded plugins have had a chance to
			-- register their keymaps, so alternative keybinds show up correctly.
			vim.defer_fn(function()
				if active and window.is_open() and not welcome_active then
					render_current()
				end
			end, 250)
		end
	end
	active = true
	progress.set_coaching_active(true)
	progress.save()

	save_autocmd = vim.api.nvim_create_autocmd("VimLeavePre", {
		callback = function()
			progress.save()
		end,
	})
end

--- Stop coaching
function M.stop()
	if not active then
		return
	end

	tracker.stop()
	progress.set_window_visible(window.is_open())
	progress.set_coaching_active(false)
	window.stop_message()
	window.close()
	progress.save()
	active = false

	if save_autocmd then
		vim.api.nvim_del_autocmd(save_autocmd)
		save_autocmd = nil
	end
end

function M.toggle()
	if active then
		M.stop()
	else
		M.start()
	end
end

function M.toggle_window()
	if not active then
		vim.notify("coach.nvim: coaching is not active. Use :CoachStart first.", vim.log.levels.WARN)
		return
	end

	local opened = window.toggle()
	progress.set_window_visible(opened)
	progress.save()
	if opened then
		render_current()
	end
end

function M.next_set()
	if not active then
		vim.notify("coach.nvim: coaching is not active.", vim.log.levels.WARN)
		return
	end

	if welcome_active then
		welcome_active = false
		progress.mark_welcome_shown()
		progress.save()
		render_current()
		return
	end

	local s = sets.get(progress.get_set_index())
	local shadowed = s and keybinds.get_shadowed(s) or {}

	if not progress.is_set_complete(shadowed) then
		vim.notify("coach.nvim: complete the current set first.", vim.log.levels.INFO)
		return
	end

	if not progress.advance() then
		vim.notify("coach.nvim: you've completed all sets!", vim.log.levels.INFO)
		return
	end

	render_current()
end

function M.skip_set()
	if not active then
		vim.notify("coach.nvim: coaching is not active.", vim.log.levels.WARN)
		return
	end

	if welcome_active then
		welcome_active = false
		progress.mark_welcome_shown()
		progress.save()
		render_current()
		return
	end

	if not progress.advance() then
		vim.notify("coach.nvim: already on the last set.", vim.log.levels.INFO)
		return
	end

	render_current()
end

function M.prev_set()
	if not active then
		vim.notify("coach.nvim: coaching is not active.", vim.log.levels.WARN)
		return
	end

	if not progress.go_back() then
		vim.notify("coach.nvim: already on the first set.", vim.log.levels.INFO)
		return
	end

	render_current()
end

--- Re-render after a reset. Resets are allowed while coaching is stopped,
--- so only touch the window when it is actually on screen.
local function after_reset()
	tracker.reset_runtime()
	if window.is_open() then
		if welcome_active then
			window.render_welcome(next_key)
		else
			render_current()
		end
	end
end

--- Clear progress for the current set.
function M.reset_set()
	progress.reset_current()
	after_reset()
	vim.notify("coach.nvim: current set reset.", vim.log.levels.INFO)
end

--- Clear progress for every set in the active session.
function M.reset_session()
	progress.reset_session()
	after_reset()
	local a = programs.get_active()
	vim.notify("coach.nvim: session reset" .. (a and (" (" .. a.session .. ")") or "") .. ".", vim.log.levels.INFO)
end

--- Clear progress for every session of the active program.
--- Destructive across many files, so it asks for confirmation first.
--- Pass `{ confirm = false }` to skip the prompt (used by tests and scripts).
---@param opts? { confirm?: boolean }
function M.reset_program(opts)
	local a = programs.get_active()
	if not a then
		vim.notify("coach.nvim: no active program.", vim.log.levels.WARN)
		return
	end

	if not opts or opts.confirm ~= false then
		local n = #programs.sessions(a.program)
		local prompt = string.format(
			"Reset ALL progress for program '%s' (%d session%s)?",
			a.program,
			n,
			n == 1 and "" or "s"
		)
		-- Default to "No" (choice 2) so a stray <CR> can't wipe progress.
		if vim.fn.confirm(prompt, "&Yes\n&No", 2, "Question") ~= 1 then
			vim.notify("coach.nvim: program reset cancelled.", vim.log.levels.INFO)
			return
		end
	end

	progress.reset_program(a.program)
	after_reset()
	vim.notify("coach.nvim: program reset (" .. a.program .. ").", vim.log.levels.INFO)
end

function M.help()
	local s = sets.get(progress.get_set_index())
	if not s or not s.help_tag then
		vim.notify("coach.nvim: no help tag for current set.", vim.log.levels.INFO)
		return
	end
	vim.cmd("help " .. s.help_tag)
end

function M.toggle_index()
	if not active then
		vim.notify("coach.nvim: coaching is not active. Use :CoachStart first.", vim.log.levels.WARN)
		return
	end

	if index.is_open() then
		index.close()
		return
	end

	window.close()

	local function on_float_restore()
		window.open()
		if welcome_active then
			window.render_welcome(next_key)
		else
			render_current()
		end
	end

	index.open(function(kind, value)
		welcome_active = false
		if kind == "set" then
			progress.go_to(value)
			window.open()
			render_current()
		elseif kind == "session" then
			local active_program = programs.get_active()
			if active_program then
				M.switch_session(active_program.program .. "/" .. value)
			else
				M.switch_session(value)
			end
			window.open()
			render_current()
		end
	end, on_float_restore)
end

---@return boolean
function M.is_active()
	return active
end

--- Switch to a session by "program/session" or just "program" (first session of that program).
---@param target string|nil
function M.switch_session(target)
	local function do_switch(program_name, session_name)
		local ok, err = programs.switch(program_name, session_name)
		if not ok then
			vim.notify("coach.nvim: " .. (err or "switch failed"), vim.log.levels.WARN)
			return
		end
		welcome_active = false
		if active and window.is_open() then
			render_current()
		end
	end

	if not target or target == "" then
		-- Picker
		local pairs_list = programs.all_session_pairs()
		if #pairs_list == 0 then
			vim.notify("coach.nvim: no sessions available.", vim.log.levels.WARN)
			return
		end
		vim.ui.select(pairs_list, {
			prompt = "Coach session:",
			format_item = function(p)
				return p.program .. "/" .. p.session
			end,
		}, function(choice)
			if choice then
				do_switch(choice.program, choice.session)
			end
		end)
		return
	end

	local slash = target:find("/", 1, true)
	if slash then
		do_switch(target:sub(1, slash - 1), target:sub(slash + 1))
	else
		do_switch(target, nil)
	end
end

--- Switch to the first session of a named program.
---@param program_name string|nil
function M.switch_program(program_name)
	if not program_name or program_name == "" then
		local program_list = programs.list()
		if #program_list == 0 then
			vim.notify("coach.nvim: no programs configured.", vim.log.levels.WARN)
			return
		end
		vim.ui.select(program_list, {
			prompt = "Coach program:",
			format_item = function(p)
				return p.name
			end,
		}, function(choice)
			if choice then
				M.switch_session(choice.name)
			end
		end)
		return
	end
	M.switch_session(program_name)
end

--- `git pull` a github program's cache and reload it.
---@param program_name string|nil  When nil, updates every github program.
function M.update_program(program_name)
	local to_update = {}
	if program_name and program_name ~= "" then
		table.insert(to_update, program_name)
	else
		for _, p in ipairs(programs.list()) do
			if sources.kind(p.source) == "github" then
				table.insert(to_update, p.name)
			end
		end
	end
	if #to_update == 0 then
		vim.notify("coach.nvim: no github programs to update.", vim.log.levels.INFO)
		return
	end
	for _, name in ipairs(to_update) do
		programs.update(name, function(ok, err)
			if ok then
				vim.notify("coach.nvim: updated '" .. name .. "'", vim.log.levels.INFO)
				if active and window.is_open() then
					render_current()
				end
			else
				vim.notify("coach.nvim: update '" .. name .. "' failed: " .. (err or ""), vim.log.levels.WARN)
			end
		end)
	end
end

--- Completion for :CoachSession
---@param arg_lead string
---@return string[]
local function complete_session(arg_lead)
	local out = {}
	for _, p in ipairs(programs.all_session_pairs()) do
		local name = p.program .. "/" .. p.session
		if name:sub(1, #arg_lead) == arg_lead then
			table.insert(out, name)
		end
	end
	return out
end

---@param arg_lead string
---@return string[]
local function complete_program(arg_lead)
	local out = {}
	for _, p in ipairs(programs.list()) do
		if p.name:sub(1, #arg_lead) == arg_lead then
			table.insert(out, p.name)
		end
	end
	return out
end

--- Setup
---@param opts? {
---   required_reps?: number,
---   progress_dir?: string,
---   log_file?: string,
---   programs?: { name: string, source?: string }[],
---   active?: string,
---   keybinds?: {
---     toggle?: string, window?: string, next?: string, prev?: string,
---     help?: string, skip?: string, index?: string, session?: string,
---   },
--- }
function M.setup(opts)
	opts = opts or {}

	log.setup({ log_file = opts.log_file })

	progress.configure({
		required_reps = opts.required_reps,
		progress_dir = opts.progress_dir,
	})

	-- Wire the switch hook: save/load progress for the new session, re-render.
	programs._on_switch = function(program_name, session_name)
		progress.switch(program_name, session_name)
		if active and window.is_open() then
			vim.schedule(render_current)
		end
	end

	programs.configure({ programs = opts.programs, active = opts.active }, function()
		local a = programs.get_active()
		if a then
			progress.switch(a.program, a.session)
			if active and window.is_open() then
				vim.schedule(render_current)
			end
		end
	end)

	-- Apply initial active immediately if one was resolved synchronously.
	local initial = programs.get_active()
	if initial then
		progress.switch(initial.program, initial.session)
	end

	-- User commands
	vim.api.nvim_create_user_command("CoachStart", function()
		M.start()
	end, {})
	vim.api.nvim_create_user_command("CoachStop", function()
		M.stop()
	end, {})
	vim.api.nvim_create_user_command("CoachToggle", function()
		M.toggle()
	end, {})
	vim.api.nvim_create_user_command("CoachWindow", function()
		M.toggle_window()
	end, {})
	vim.api.nvim_create_user_command("CoachNext", function()
		M.next_set()
	end, {})
	vim.api.nvim_create_user_command("CoachPrev", function()
		M.prev_set()
	end, {})
	vim.api.nvim_create_user_command("CoachReset", function()
		M.reset_set()
	end, {})
	vim.api.nvim_create_user_command("CoachResetSession", function()
		M.reset_session()
	end, {})
	vim.api.nvim_create_user_command("CoachResetProgram", function(args)
		-- `:CoachResetProgram!` skips the confirmation prompt.
		M.reset_program({ confirm = not args.bang })
	end, { bang = true })
	vim.api.nvim_create_user_command("CoachSkip", function()
		M.skip_set()
	end, {})
	vim.api.nvim_create_user_command("CoachHelp", function()
		M.help()
	end, {})
	vim.api.nvim_create_user_command("CoachIndex", function()
		M.toggle_index()
	end, {})
	vim.api.nvim_create_user_command("CoachSession", function(args)
		M.switch_session(args.args)
	end, { nargs = "?", complete = complete_session })
	vim.api.nvim_create_user_command("CoachProgram", function(args)
		M.switch_program(args.args)
	end, { nargs = "?", complete = complete_program })
	vim.api.nvim_create_user_command("CoachUpdate", function(args)
		M.update_program(args.args)
	end, { nargs = "?", complete = complete_program })

	-- Keybindings
	local keys = vim.tbl_extend("force", {
		toggle = "<leader>kk",
		window = "<leader>kw",
		next = "<leader>kn",
		prev = "<leader>kp",
		help = "<leader>kh",
		skip = "<leader>ks",
		index = "<leader>ki",
		session = "<leader>kS",
	}, opts.keybinds or {})

	next_key = keys.next
	tracker.set_next_key(next_key)

	vim.keymap.set("n", keys.toggle, function()
		M.toggle()
	end, { desc = "Coach: toggle" })
	vim.keymap.set("n", keys.window, function()
		M.toggle_window()
	end, { desc = "Coach: toggle window" })
	vim.keymap.set("n", keys.next, function()
		M.next_set()
	end, { desc = "Coach: next set" })
	vim.keymap.set("n", keys.prev, function()
		M.prev_set()
	end, { desc = "Coach: prev set" })
	vim.keymap.set("n", keys.help, function()
		M.help()
	end, { desc = "Coach: open help section" })
	vim.keymap.set("n", keys.skip, function()
		M.skip_set()
	end, { desc = "Coach: skip set" })
	vim.keymap.set("n", keys.index, function()
		M.toggle_index()
	end, { desc = "Coach: toggle index" })
	if keys.session then
		vim.keymap.set("n", keys.session, function()
			M.switch_session(nil)
		end, { desc = "Coach: pick session" })
	end

	-- Auto-start if coaching was active last session.
	-- Defer to VimEnter so lazy-loaded plugins have registered their keymaps
	-- before we render the alternative-keybind section.
	progress.load()
	if progress.is_coaching_active() then
		if vim.v.vim_did_enter == 1 then
			M.start()
		else
			vim.api.nvim_create_autocmd("VimEnter", {
				once = true,
				callback = function()
					M.start()
				end,
			})
		end
	end
end

return M
