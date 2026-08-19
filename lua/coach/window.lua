-- Floating window for displaying set/exercise progress

local M = {}

---@type number|nil
local buf = nil

---@type number|nil
local win = nil

--- Highlight group names
local HL_ACTION = "CoachAction"
local HL_DESC = "CoachDesc"
local HL_BAR_FILLED = "CoachBarFilled"
local HL_BAR_EMPTY = "CoachBarEmpty"
local HL_COUNT = "CoachCount"
local HL_TICK = "CoachTick"
local HL_COMPLETE = "CoachComplete"
local HL_HINT = "CoachHint"
local HL_WARN = "CoachWarn"
local HL_SHADOWED = "CoachShadowed"
-- Same treatment as shadowed, and a separate group so a colourscheme can tell the
-- two apart: "you remapped this" and "Neovim cannot report this" are different
-- facts, even though both mean the row is not waiting for you.
local HL_UNSUPPORTED = "CoachUnsupported"

--- Setup highlight groups
local function setup_highlights()
	local set = vim.api.nvim_set_hl
	set(0, "CoachNormal", { link = "NormalFloat", default = true })
	set(0, "CoachBorder", { link = "FloatBorder", default = true })
	set(0, "CoachTitle", { link = "FloatTitle", default = true })
	set(0, HL_ACTION, { bold = true, fg = "#7aa2f7", default = true })
	set(0, HL_DESC, { fg = "#a9b1d6", default = true })
	set(0, HL_BAR_FILLED, { fg = "#9ece6a", default = true })
	set(0, HL_BAR_EMPTY, { fg = "#3b4261", default = true })
	set(0, HL_COUNT, { fg = "#a9b1d6", default = true })
	set(0, HL_TICK, { fg = "#9ece6a", bold = true, default = true })
	set(0, HL_COMPLETE, { fg = "#9ece6a", bold = true, default = true })
	set(0, HL_HINT, { fg = "#7aa2f7", italic = true, default = true })
	set(0, HL_WARN, { fg = "#e0af68", italic = true, default = true })
	set(0, HL_SHADOWED, { fg = "#565f89", italic = true, default = true })
	set(0, HL_UNSUPPORTED, { fg = "#565f89", italic = true, default = true })
end

--- Build a progress bar string
---@param count number
---@param total number
---@param width number
---@return string filled, string empty
local function progress_bar(count, total, width)
	local filled = math.floor((count / total) * width)
	if count > 0 and filled == 0 then
		filled = 1
	end
	if filled > width then
		filled = width
	end
	local empty = width - filled
	return string.rep("\u{2588}", filled), string.rep("\u{2591}", empty)
end

--- Pad `s` on the right to `width` **display** columns.
---
--- Columns used to be padded with `#str` and `%-Ns`, which count bytes, so a
--- description holding a typographic dash -- shorter on screen than in bytes --
--- pushed its row's progress bar left of every other row's. Extmark columns are
--- still byte offsets, which is why the highlight maths below keeps using `#`.
---@param s string
---@param width number Target display width
---@return string
local function pad_display(s, width)
	local pad = width - vim.fn.strdisplaywidth(s)
	return s .. string.rep(" ", math.max(pad, 0))
end

--- Floating window geometry, overridable through `setup({ window = ... })`.
---@class coach.WindowConfig
---@field width number
---@field height number
---@field position "top-right"|"top-left"|"bottom-right"|"bottom-left"
---@field row number|nil Explicit row, which wins over `position`
---@field col number|nil Explicit column, which wins over `position`
local DEFAULT_GEOMETRY = {
	width = 34,
	height = 8,
	position = "top-right",
	row = nil,
	col = nil,
}

---@type coach.WindowConfig
local geometry = vim.deepcopy(DEFAULT_GEOMETRY)

--- Set the window geometry. Anything not given falls back to the default, so
--- `configure({})` restores it.
---@param opts table|nil
function M.configure(opts)
	geometry = vim.tbl_extend("force", vim.deepcopy(DEFAULT_GEOMETRY), opts or {})
end

--- Where the float goes, in editor coordinates.
---@return number width, number height, number row, number col
local function resolve_geometry()
	local width = math.max(math.floor(geometry.width or DEFAULT_GEOMETRY.width), 1)
	local height = math.max(math.floor(geometry.height or DEFAULT_GEOMETRY.height), 1)

	-- The same margins the window has always used: 2 columns from the side, one row
	-- from the top, and four from the bottom to clear the statusline and cmdline.
	local right = math.max(vim.o.columns - width - 2, 0)
	local bottom = math.max(vim.o.lines - height - 4, 0)
	local corners = {
		["top-right"] = { row = 1, col = right },
		["top-left"] = { row = 1, col = 2 },
		["bottom-right"] = { row = bottom, col = right },
		["bottom-left"] = { row = bottom, col = 2 },
	}
	-- An unknown position is not worth refusing to open over.
	local corner = corners[geometry.position] or corners[DEFAULT_GEOMETRY.position]

	return width, height, geometry.row or corner.row, geometry.col or corner.col
end

--- Pending message to display (set externally, cleared after render)
---@type string|nil
local pending_message = nil

--- Timer for clearing the message
local message_timer = nil

--- How long a message stays up, in milliseconds
local MESSAGE_TIMEOUT = 2000

--- Clear the message and redraw without it.
local function expire_message()
	pending_message = nil
	-- Re-render to clear the message (caller must provide a re-render hook)
	if M._rerender then
		M._rerender()
	end
end

--- One scheduled wrapper, reused by every restart of the timer.
local on_message_timeout = vim.schedule_wrap(expire_message)

--- Set a temporary message to show on next render
---@param msg string
function M.set_message(msg)
	pending_message = msg

	-- The handle is allocated once and restarted. The timeout callback used to
	-- drop the reference with `message_timer = nil`, which leaks the handle for
	-- the rest of the session -- one per anti-spam message that fires.
	if not message_timer then
		message_timer = vim.uv.new_timer()
		if not message_timer then
			return
		end
	end
	message_timer:stop()
	message_timer:start(MESSAGE_TIMEOUT, 0, on_message_timeout)
end

--- Drop any pending message and release the timer. Called when coaching stops.
function M.stop_message()
	if message_timer then
		message_timer:stop()
		if not message_timer:is_closing() then
			message_timer:close()
		end
		message_timer = nil
	end
	pending_message = nil
end

--- Fire the message timeout now, for tests, instead of waiting 2s.
function M._expire_message()
	if message_timer then
		message_timer:stop()
	end
	expire_message()
end

--- The message currently pending, for tests.
---@return string|nil
function M._pending_message()
	return pending_message
end

--- Render the window contents
---@param set table Set definition (one entry from a session)
---@param counts table<string, number> Exercise counts
---@param required_reps number
---@param next_key string Keybind for next set
---@param shadowed? table<string, any> Map of shadowed exercise keys
---@param alternatives? table<string, string[]> Alternative keybind displays per exercise
function M.render(set, counts, required_reps, next_key, shadowed, alternatives)
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		return
	end

	shadowed = shadowed or {}
	-- Not a parameter, unlike `shadowed`: which keys the user has remapped is a fact
	-- about the user and only the caller knows it, while which actions Neovim can
	-- report is a fact about Neovim. Reading it here keeps four call sites unchanged.
	local unsupported = require("coach.unsupported")
	alternatives = alternatives or {}
	local bar_width = 6
	local lines = {}
	local highlights = {} -- { line, col_start, col_end, hl_group }

	-- Help tag reference
	if set.help_tag then
		local ref = "  :h " .. set.help_tag
		table.insert(lines, ref)
		table.insert(highlights, { #lines - 1, 2, #ref, HL_HINT })
		table.insert(lines, "")
	else
		table.insert(lines, "")
	end

	-- Compute display and description column widths dynamically
	local display_width = 0
	local desc_width = 0
	for _, e in ipairs(set.exercises) do
		local d = e.display
		local inert = shadowed[e.exercise] or unsupported.is(e.exercise)
		if not inert and alternatives[e.exercise] and #alternatives[e.exercise] > 0 then
			d = d .. " / " .. table.concat(alternatives[e.exercise], " / ")
		end
		display_width = math.max(display_width, vim.fn.strdisplaywidth(d) + 2)
		desc_width = math.max(desc_width, vim.fn.strdisplaywidth(e.desc) + 2)
	end

	-- Exercise lines
	local all_complete = true
	for _, e in ipairs(set.exercises) do
		-- Build display string with alternatives
		local display_text = e.display
		local is_unsupported = unsupported.is(e.exercise)
		local inert = shadowed[e.exercise] or is_unsupported
		if not inert and alternatives[e.exercise] and #alternatives[e.exercise] > 0 then
			display_text = display_text .. " / " .. table.concat(alternatives[e.exercise], " / ")
		end
		local display = pad_display(display_text, display_width)
		local desc_str = pad_display(e.desc, desc_width)
		local line_idx = #lines

		if inert then
			-- Shadowed or unsupported: a dim indicator instead of progress, because
			-- no amount of pressing will fill a bar for either. Both are excluded
			-- from `is_set_complete`, so neither blocks `:CoachNext`.
			--
			-- Worded as a current limitation rather than as the user's problem: an
			-- unsupported row is a thing Neovim does not report, not a thing they
			-- did wrong.
			local unsupported_row = is_unsupported and not shadowed[e.exercise]
			local indicator = unsupported_row and "\u{2014} unsupported" or "\u{2014} shadowed"
			local hl = unsupported_row and HL_UNSUPPORTED or HL_SHADOWED
			local line = "  " .. display .. desc_str .. indicator
			table.insert(lines, line)

			local col = 2
			table.insert(highlights, { line_idx, col, col + #display, HL_ACTION })
			col = col + #display
			table.insert(highlights, { line_idx, col, col + #desc_str, hl })
			col = col + #desc_str
			table.insert(highlights, { line_idx, col, col + #indicator, hl })
		else
			local count = math.min(counts[e.exercise] or 0, required_reps)
			local complete = count >= required_reps
			if not complete then
				all_complete = false
			end

			local filled, empty = progress_bar(count, required_reps, bar_width)
			local count_str = string.format("%2d/%d", count, required_reps)
			local tick = complete and " \u{2713}" or ""

			local line = "  " .. display .. desc_str .. filled .. empty .. " " .. count_str .. tick
			table.insert(lines, line)

			-- Highlights for display (base key + alternatives)
			local col = 2
			local base_len = #e.display
			table.insert(highlights, { line_idx, col, col + base_len, HL_ACTION })
			if #display_text > base_len then
				table.insert(highlights, { line_idx, col + base_len, col + #display_text, HL_HINT })
			end
			col = col + #display
			table.insert(highlights, { line_idx, col, col + #desc_str, HL_DESC })
			col = col + #desc_str
			table.insert(highlights, { line_idx, col, col + #filled, HL_BAR_FILLED })
			col = col + #filled
			table.insert(highlights, { line_idx, col, col + #empty, HL_BAR_EMPTY })
			col = col + #empty + 1
			table.insert(highlights, { line_idx, col, col + #count_str, HL_COUNT })
			if complete then
				col = col + #count_str
				table.insert(highlights, { line_idx, col, col + #tick, HL_TICK })
			end
		end
	end

	-- Completion message
	if all_complete then
		table.insert(lines, "")
		local msg = "  Set Complete!"
		table.insert(lines, msg)
		table.insert(highlights, { #lines - 1, 2, #msg, HL_COMPLETE })

		local hint = "  " .. next_key .. "  next set"
		table.insert(lines, hint)
		table.insert(highlights, { #lines - 1, 2, #hint, HL_HINT })
	end

	-- Temporary message (e.g. anti-spam warning)
	if pending_message then
		table.insert(lines, "")
		local warn = "  " .. pending_message
		table.insert(lines, warn)
		table.insert(highlights, { #lines - 1, 2, #warn, HL_WARN })
	end

	-- Bottom padding
	table.insert(lines, "")

	-- Write to buffer
	vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

	-- Apply highlights
	local ns = vim.api.nvim_create_namespace("coach")
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	for _, hl in ipairs(highlights) do
		vim.api.nvim_buf_set_extmark(buf, ns, hl[1], hl[2], { end_col = hl[3], hl_group = hl[4] })
	end

	-- Update title and resize
	if win and vim.api.nvim_win_is_valid(win) then
		local width = 0
		for _, line in ipairs(lines) do
			local w = vim.fn.strdisplaywidth(line)
			if w > width then
				width = w
			end
		end
		local title = " " .. set.title .. " (" .. set.id .. ") "
		width = math.max(width + 2, vim.fn.strdisplaywidth(title) + 2)

		vim.api.nvim_win_set_config(win, {
			relative = "editor",
			width = width,
			height = #lines,
			col = vim.o.columns - width - 2,
			row = 1,
			title = { { title, "CoachTitle" } },
			title_pos = "center",
		})
	end
end

--- Render the welcome screen in the floating window
---@param next_key string Keybind for starting the first set
function M.render_welcome(next_key)
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		return
	end

	local lines = {}
	local highlights = {} -- { line, col_start, col_end, hl_group }

	-- Title
	local title_line = "  coach.nvim"
	table.insert(lines, title_line)
	table.insert(highlights, { 0, 2, #title_line, HL_COMPLETE })

	table.insert(lines, "")

	-- Description
	local desc1 = "  Learn Neovim keybindings through sessions"
	local desc2 = "  from the user manual."
	table.insert(lines, desc1)
	table.insert(highlights, { #lines - 1, 2, #desc1, HL_DESC })
	table.insert(lines, desc2)
	table.insert(highlights, { #lines - 1, 2, #desc2, HL_DESC })

	table.insert(lines, "")

	-- Bullet points
	local bullets = {
		"  \u{2022} Track exercises in your workflow",
		"  \u{2022} Complete reps to advance",
	}
	for _, b in ipairs(bullets) do
		table.insert(lines, b)
		table.insert(highlights, { #lines - 1, 2, #b, HL_DESC })
	end

	table.insert(lines, "")

	-- Keybind hint
	local hint = "  " .. next_key .. "  begin first set"
	table.insert(lines, hint)
	table.insert(highlights, { #lines - 1, 2, #hint, HL_HINT })

	table.insert(lines, "")

	-- Write to buffer
	vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

	-- Apply highlights
	local ns = vim.api.nvim_create_namespace("coach")
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	for _, hl in ipairs(highlights) do
		vim.api.nvim_buf_set_extmark(buf, ns, hl[1], hl[2], { end_col = hl[3], hl_group = hl[4] })
	end

	-- Resize window to fit
	if win and vim.api.nvim_win_is_valid(win) then
		local width = 0
		for _, line in ipairs(lines) do
			local w = vim.fn.strdisplaywidth(line)
			if w > width then
				width = w
			end
		end
		width = width + 2

		vim.api.nvim_win_set_config(win, {
			relative = "editor",
			width = width,
			height = #lines,
			col = vim.o.columns - width - 2,
			row = 1,
			title = { { " coach.nvim ", "CoachTitle" } },
			title_pos = "center",
		})
	end
end

--- Open the floating window
---@param title? string Initial title
function M.open(title)
	setup_highlights()

	if win and vim.api.nvim_win_is_valid(win) then
		return
	end

	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
		vim.api.nvim_set_option_value("bufhidden", "hide", { buf = buf })
		vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
	end

	local win_width, win_height, win_row, win_col = resolve_geometry()

	local display_title = title and (" " .. title .. " ") or " Coach "

	win = vim.api.nvim_open_win(buf, false, {
		relative = "editor",
		width = win_width,
		height = win_height,
		col = win_col,
		row = win_row,
		style = "minimal",
		border = "rounded",
		title = { { display_title, "CoachTitle" } },
		title_pos = "center",
		focusable = false,
		noautocmd = true,
	})

	vim.api.nvim_set_option_value("winhighlight", "Normal:CoachNormal,FloatBorder:CoachBorder", { win = win })
end

--- The float's buffer and window, for tests.
---@return number|nil
function M._buf()
	return buf
end

---@return number|nil
function M._win()
	return win
end

--- Close the floating window
function M.close()
	if win and vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_win_close(win, true)
	end
	win = nil
end

--- Toggle window visibility
---@return boolean is_open
function M.toggle()
	if M.is_open() then
		M.close()
		return false
	else
		M.open()
		return true
	end
end

--- Check if window is visible
---@return boolean
function M.is_open()
	return win ~= nil and vim.api.nvim_win_is_valid(win)
end

return M
