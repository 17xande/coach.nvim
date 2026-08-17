-- Index sidebar window showing all sets in the active session
-- plus the other sessions in the same program for quick navigation.

local sets = require("coach.sets")
local progress = require("coach.progress")
local programs = require("coach.programs")

local M = {}

---@type number|nil
local buf = nil

---@type number|nil
local win = nil

--- Map from 0-based line index to a selectable target.
--- Each entry is { kind = "set"|"session", value = number|string }.
---@type table<number, { kind: string, value: any }>
local line_targets = {}

--- Callback to invoke when the index is dismissed without selecting
---@type function|nil
local pending_on_close = nil

local function setup_highlights()
	local set = vim.api.nvim_set_hl
	set(0, "CoachIndexCurrent", { bold = true, fg = "#7aa2f7", default = true })
	set(0, "CoachIndexComplete", { fg = "#9ece6a", default = true })
	set(0, "CoachIndexProgress", { fg = "#7dcfff", default = true })
	set(0, "CoachIndexTitle", { fg = "#a9b1d6", default = true })
	set(0, "CoachIndexMuted", { fg = "#565f89", default = true })
	set(0, "CoachIndexSession", { fg = "#bb9af7", default = true })
end

--- Build the rendered lines and highlight ranges.
---@param current_index number Current set index in the active session
---@param all_counts table<string, table<string, number>> Counts keyed by set id
---@param required_reps number Global required reps default
local function render(current_index, all_counts, required_reps)
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		return
	end

	line_targets = {}
	local lines = {}
	local highlights = {} -- { line_idx, col_start, col_end, hl_group }

	local active = programs.get_active()
	local program_name = active and active.program or ""
	local active_session = active and active.session or ""

	-- Header: program name
	local header = "  " .. program_name
	table.insert(lines, header)
	table.insert(highlights, { 0, 2, #header, "CoachIndexTitle" })
	table.insert(lines, "")

	-- Subheader: active session name
	if active_session ~= "" then
		local sub = "  " .. active_session
		table.insert(lines, sub)
		table.insert(highlights, { #lines - 1, 2, #sub, "CoachIndexSession" })
	end

	-- Sets in the active session
	local count = sets.count()
	for i = 1, count do
		local s = sets.get(i)
		if s then
			local set_counts = all_counts[s.id] or {}
			local is_current = (i == current_index)
			local set_reps = s.required_reps or required_reps

			-- Determine completion status
			local all_done = true
			local any_progress = false
			for _, e in ipairs(s.exercises) do
				local c = set_counts[e.exercise] or 0
				if c > 0 then
					any_progress = true
				end
				if c < set_reps then
					all_done = false
				end
			end
			local is_complete = all_done and #s.exercises > 0

			local icon
			local hl_group
			if is_current then
				icon = "\u{25B6} " -- ▶  current set (always takes priority)
				hl_group = "CoachIndexCurrent"
			elseif is_complete then
				icon = "\u{2713} " -- ✓  fully done
				hl_group = "CoachIndexComplete"
			elseif any_progress then
				icon = "\u{25CF} " -- ●  started but not done
				hl_group = "CoachIndexProgress"
			else
				icon = "  " -- not started
				hl_group = "CoachIndexMuted"
			end

			local id_str = string.format("%-6s", s.id)
			local line = "    " .. icon .. id_str .. s.title
			local line_idx = #lines
			line_targets[line_idx] = { kind = "set", value = i }
			table.insert(lines, line)
			table.insert(highlights, { line_idx, 4, #line, hl_group })
		end
	end

	-- Other sessions in the same program
	if program_name ~= "" then
		local sessions = programs.sessions(program_name)
		local others = {}
		for _, sess in ipairs(sessions) do
			if sess.name ~= active_session then
				table.insert(others, sess.name)
			end
		end

		if #others > 0 then
			table.insert(lines, "")
			local section = "  Other sessions"
			table.insert(lines, section)
			table.insert(highlights, { #lines - 1, 2, #section, "CoachIndexTitle" })

			for _, name in ipairs(others) do
				local line = "    " .. name
				local line_idx = #lines
				line_targets[line_idx] = { kind = "session", value = name }
				table.insert(lines, line)
				table.insert(highlights, { line_idx, 4, #line, "CoachIndexSession" })
			end
		end
	end

	-- Footer hint
	table.insert(lines, "")
	local hint = "  <CR> select   q close"
	table.insert(lines, hint)
	table.insert(highlights, { #lines - 1, 2, #hint, "CoachIndexMuted" })

	-- Write to buffer
	vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

	-- Apply highlights
	local ns = vim.api.nvim_create_namespace("coach_index")
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	for _, hl in ipairs(highlights) do
		vim.api.nvim_buf_set_extmark(buf, ns, hl[1], hl[2], { end_col = hl[3], hl_group = hl[4] })
	end

	-- Move cursor to the current set row
	if win and vim.api.nvim_win_is_valid(win) then
		for lnum, target in pairs(line_targets) do
			if target.kind == "set" and target.value == current_index then
				pcall(vim.api.nvim_win_set_cursor, win, { lnum + 1, 0 })
				break
			end
		end
	end
end

--- Open the index sidebar window.
--- `on_select` is called with (kind, value) where:
---   kind = "set"     → value is a 1-based set index in the current session
---   kind = "session" → value is the session name to switch to
---@param on_select function|nil Called when user picks an entry
---@param on_close function|nil Called when the index is dismissed without selecting
function M.open(on_select, on_close)
	setup_highlights()

	if win and vim.api.nvim_win_is_valid(win) then
		return
	end

	pending_on_close = on_close

	buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
	vim.api.nvim_set_option_value("swapfile", false, { buf = buf })

	vim.cmd("botright vsplit")
	win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_buf(win, buf)
	vim.api.nvim_win_set_width(win, 44)

	-- Window options
	vim.api.nvim_set_option_value("wrap", false, { win = win })
	vim.api.nvim_set_option_value("number", false, { win = win })
	vim.api.nvim_set_option_value("relativenumber", false, { win = win })
	vim.api.nvim_set_option_value("signcolumn", "no", { win = win })
	vim.api.nvim_set_option_value("cursorline", true, { win = win })
	vim.api.nvim_set_option_value("winhighlight", "Normal:NormalFloat", { win = win })

	-- Clean up state when window is closed (externally or via M.close)
	vim.api.nvim_create_autocmd("WinClosed", {
		pattern = tostring(win),
		once = true,
		callback = function()
			win = nil
			buf = nil
			local cb = pending_on_close
			pending_on_close = nil
			if cb then
				cb()
			end
		end,
	})

	render(progress.get_set_index(), progress.get_all_set_counts(), progress.get_required_reps())

	local function pick()
		local cursor_line = vim.api.nvim_win_get_cursor(win)[1] - 1
		local target = line_targets[cursor_line]
		if target and on_select then
			pending_on_close = nil -- selecting: don't fire on_close
			M.close()
			on_select(target.kind, target.value)
		end
	end

	local opts = { buffer = buf, nowait = true, silent = true }
	vim.keymap.set("n", "<CR>", pick, opts)
	vim.keymap.set("n", "q", function()
		M.close()
	end, opts)
	vim.keymap.set("n", "<Esc>", function()
		M.close()
	end, opts)
end

--- Redraw the sidebar against the current progress, if it is open.
---
--- It used to render once, at open, so reps counted (or a reset performed) while
--- it was up left it showing the state it had when it opened. Called from the
--- tracker's post-increment path and from `init`'s `after_reset`.
function M.refresh()
	if not M.is_open() then
		return
	end
	render(progress.get_set_index(), progress.get_all_set_counts(), progress.get_required_reps())
end

--- The sidebar's buffer, for tests.
---@return number|nil
function M._buf()
	return buf
end

--- Close the index window
function M.close()
	if win and vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_win_close(win, true)
	end
	win = nil
	buf = nil
end

--- Check if the index window is open
---@return boolean
function M.is_open()
	return win ~= nil and vim.api.nvim_win_is_valid(win)
end

--- Toggle the index window
---@param on_select function|nil
---@param on_close function|nil
function M.toggle(on_select, on_close)
	if M.is_open() then
		M.close()
	else
		M.open(on_select, on_close)
	end
end

return M
