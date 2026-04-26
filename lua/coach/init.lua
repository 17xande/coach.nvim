-- coach.nvim - Neovim keybinding coach
-- Public API

local exercises = require("coach.exercises")
local index = require("coach.index")
local keybinds = require("coach.keybinds")
local log = require("coach.log")
local progress = require("coach.progress")
local sets = require("coach.sets")
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

--- Render the current exercise in the window
local function render_current()
	local exercise = exercises.get(progress.get_exercise_index())
	if exercise then
		local shadowed = keybinds.get_shadowed(exercise)
		local alternatives = keybinds.get_alternatives(exercise)
		local reps = exercise.required_reps or progress.get_required_reps()
		window.render(exercise, progress.get_counts(), reps, next_key, shadowed, alternatives)
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

function M.next_exercise()
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

	local exercise = exercises.get(progress.get_exercise_index())
	local shadowed = exercise and keybinds.get_shadowed(exercise) or {}

	if not progress.is_exercise_complete(shadowed) then
		vim.notify("coach.nvim: complete the current exercise first.", vim.log.levels.INFO)
		return
	end

	if not progress.advance() then
		vim.notify("coach.nvim: you've completed all exercises!", vim.log.levels.INFO)
		return
	end

	render_current()
end

function M.skip_exercise()
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
		vim.notify("coach.nvim: already on the last exercise.", vim.log.levels.INFO)
		return
	end

	render_current()
end

function M.prev_exercise()
	if not active then
		vim.notify("coach.nvim: coaching is not active.", vim.log.levels.WARN)
		return
	end

	if not progress.go_back() then
		vim.notify("coach.nvim: already on the first exercise.", vim.log.levels.INFO)
		return
	end

	render_current()
end

function M.reset_exercise()
	if not active then
		vim.notify("coach.nvim: coaching is not active.", vim.log.levels.WARN)
		return
	end

	progress.reset_current()
	render_current()
	vim.notify("coach.nvim: current exercise reset.", vim.log.levels.INFO)
end

function M.reset_all()
	if not active then
		vim.notify("coach.nvim: coaching is not active.", vim.log.levels.WARN)
		return
	end

	progress.reset_all()
	render_current()
	vim.notify("coach.nvim: all progress reset.", vim.log.levels.INFO)
end

function M.help()
	local exercise = exercises.get(progress.get_exercise_index())
	if not exercise or not exercise.help_tag then
		vim.notify("coach.nvim: no help tag for current exercise.", vim.log.levels.INFO)
		return
	end
	vim.cmd("help " .. exercise.help_tag)
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

	index.open(function(ex_idx)
		progress.go_to(ex_idx)
		welcome_active = false
		window.open()
		render_current()
	end, on_float_restore)
end

---@return boolean
function M.is_active()
	return active
end

--- Switch to a volume by "set/volume" or just "set" (first volume of that set).
---@param target string|nil
function M.switch_volume(target)
	local function do_switch(set_name, volume_name)
		local ok, err = sets.switch(set_name, volume_name)
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
		local pairs_list = sets.all_volume_pairs()
		if #pairs_list == 0 then
			vim.notify("coach.nvim: no volumes available.", vim.log.levels.WARN)
			return
		end
		vim.ui.select(pairs_list, {
			prompt = "Coach volume:",
			format_item = function(p)
				return p.set .. "/" .. p.volume
			end,
		}, function(choice)
			if choice then
				do_switch(choice.set, choice.volume)
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

--- Switch to the first volume of a named set.
---@param set_name string|nil
function M.switch_set(set_name)
	if not set_name or set_name == "" then
		local set_list = sets.list()
		if #set_list == 0 then
			vim.notify("coach.nvim: no sets configured.", vim.log.levels.WARN)
			return
		end
		vim.ui.select(set_list, {
			prompt = "Coach set:",
			format_item = function(s)
				return s.name
			end,
		}, function(choice)
			if choice then
				M.switch_volume(choice.name)
			end
		end)
		return
	end
	M.switch_volume(set_name)
end

--- `git pull` a github set's cache and reload it.
---@param set_name string|nil  When nil, updates every github set.
function M.update_set(set_name)
	local to_update = {}
	if set_name and set_name ~= "" then
		table.insert(to_update, set_name)
	else
		for _, s in ipairs(sets.list()) do
			if sources.kind(s.source) == "github" then
				table.insert(to_update, s.name)
			end
		end
	end
	if #to_update == 0 then
		vim.notify("coach.nvim: no github sets to update.", vim.log.levels.INFO)
		return
	end
	for _, name in ipairs(to_update) do
		sets.update(name, function(ok, err)
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

--- Completion for :CoachVolume
---@param arg_lead string
---@return string[]
local function complete_volume(arg_lead)
	local out = {}
	for _, p in ipairs(sets.all_volume_pairs()) do
		local name = p.set .. "/" .. p.volume
		if name:sub(1, #arg_lead) == arg_lead then
			table.insert(out, name)
		end
	end
	return out
end

---@param arg_lead string
---@return string[]
local function complete_set(arg_lead)
	local out = {}
	for _, s in ipairs(sets.list()) do
		if s.name:sub(1, #arg_lead) == arg_lead then
			table.insert(out, s.name)
		end
	end
	return out
end

--- Setup
---@param opts? {
---   required_reps?: number,
---   progress_dir?: string,
---   log_file?: string,
---   sets?: { name: string, source?: string }[],
---   active?: string,
---   keybinds?: {
---     toggle?: string, window?: string, next?: string, prev?: string,
---     help?: string, skip?: string, index?: string, volume?: string,
---   },
--- }
function M.setup(opts)
	opts = opts or {}

	log.setup({ log_file = opts.log_file })

	progress.configure({
		required_reps = opts.required_reps,
		progress_dir = opts.progress_dir,
	})

	-- Wire the switch hook: save/load progress for the new volume, re-render.
	sets._on_switch = function(set_name, volume_name)
		progress.switch(set_name, volume_name)
		if active and window.is_open() then
			vim.schedule(render_current)
		end
	end

	sets.configure({ sets = opts.sets, active = opts.active }, function()
		local a = sets.get_active()
		if a then
			progress.switch(a.set, a.volume)
			if active and window.is_open() then
				vim.schedule(render_current)
			end
		end
	end)

	-- Apply initial active immediately if one was resolved synchronously.
	local initial = sets.get_active()
	if initial then
		progress.switch(initial.set, initial.volume)
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
		M.next_exercise()
	end, {})
	vim.api.nvim_create_user_command("CoachPrev", function()
		M.prev_exercise()
	end, {})
	vim.api.nvim_create_user_command("CoachReset", function()
		M.reset_exercise()
	end, {})
	vim.api.nvim_create_user_command("CoachResetAll", function()
		M.reset_all()
	end, {})
	vim.api.nvim_create_user_command("CoachSkip", function()
		M.skip_exercise()
	end, {})
	vim.api.nvim_create_user_command("CoachHelp", function()
		M.help()
	end, {})
	vim.api.nvim_create_user_command("CoachIndex", function()
		M.toggle_index()
	end, {})
	vim.api.nvim_create_user_command("CoachVolume", function(args)
		M.switch_volume(args.args)
	end, { nargs = "?", complete = complete_volume })
	vim.api.nvim_create_user_command("CoachSet", function(args)
		M.switch_set(args.args)
	end, { nargs = "?", complete = complete_set })
	vim.api.nvim_create_user_command("CoachUpdate", function(args)
		M.update_set(args.args)
	end, { nargs = "?", complete = complete_set })

	-- Keybindings
	local keys = vim.tbl_extend("force", {
		toggle = "<leader>kk",
		window = "<leader>kw",
		next = "<leader>kn",
		prev = "<leader>kp",
		help = "<leader>kh",
		skip = "<leader>ks",
		index = "<leader>ki",
		volume = "<leader>kv",
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
		M.next_exercise()
	end, { desc = "Coach: next exercise" })
	vim.keymap.set("n", keys.prev, function()
		M.prev_exercise()
	end, { desc = "Coach: prev exercise" })
	vim.keymap.set("n", keys.help, function()
		M.help()
	end, { desc = "Coach: open help section" })
	vim.keymap.set("n", keys.skip, function()
		M.skip_exercise()
	end, { desc = "Coach: skip exercise" })
	vim.keymap.set("n", keys.index, function()
		M.toggle_index()
	end, { desc = "Coach: toggle index" })
	if keys.volume then
		vim.keymap.set("n", keys.volume, function()
			M.switch_volume(nil)
		end, { desc = "Coach: pick volume" })
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
