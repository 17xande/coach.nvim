-- Index sidebar window showing all exercises

local exercises = require("coach.exercises")
local progress = require("coach.progress")

local M = {}

---@type number|nil
local buf = nil

---@type number|nil
local win = nil

--- Map from 0-based line index to 1-based exercise index
---@type table<number, number>
local line_to_exercise = {}

--- Callback to invoke when the index is dismissed without selecting
---@type function|nil
local pending_on_close = nil

local function setup_highlights()
  local set = vim.api.nvim_set_hl
  set(0, "CoachIndexCurrent",  { bold = true, fg = "#7aa2f7", default = true })
  set(0, "CoachIndexComplete", { fg = "#9ece6a", default = true })
  set(0, "CoachIndexProgress", { fg = "#7dcfff", default = true })
  set(0, "CoachIndexTitle",    { fg = "#a9b1d6", default = true })
  set(0, "CoachIndexMuted",    { fg = "#565f89", default = true })
end

local function render(current_index, all_counts, required_reps)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  line_to_exercise = {}
  local lines = {}
  local highlights = {} -- { line_idx, col_start, col_end, hl_group }

  -- Header
  table.insert(lines, "  Exercises")
  table.insert(highlights, { 0, 2, #"  Exercises", "CoachIndexTitle" })
  table.insert(lines, "")

  local count = exercises.count()
  for i = 1, count do
    local ex = exercises.get(i)
    if ex then
      local ex_counts = all_counts[ex.id] or {}
      local is_current = (i == current_index)
      local ex_reps = ex.required_reps or required_reps

      -- Determine completion status
      local all_done = true
      local any_progress = false
      for _, a in ipairs(ex.actions) do
        local c = ex_counts[a.action] or 0
        if c > 0 then
          any_progress = true
        end
        if c < ex_reps then
          all_done = false
        end
      end
      local is_complete = all_done and #ex.actions > 0

      local icon
      local hl_group
      if is_current then
        icon = "\u{25B6} "   -- ▶  current exercise (always takes priority)
        hl_group = "CoachIndexCurrent"
      elseif is_complete then
        icon = "\u{2713} "   -- ✓  fully done
        hl_group = "CoachIndexComplete"
      elseif any_progress then
        icon = "\u{25CF} "   -- ●  started but not done
        hl_group = "CoachIndexProgress"
      else
        icon = "  "           -- not started
        hl_group = "CoachIndexMuted"
      end

      local id_str = string.format("%-6s", ex.id)
      local line = "  " .. icon .. id_str .. ex.title
      local line_idx = #lines
      line_to_exercise[line_idx] = i
      table.insert(lines, line)
      table.insert(highlights, { line_idx, 2, #line, hl_group })
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
    vim.api.nvim_buf_add_highlight(buf, ns, hl[4], hl[1], hl[2], hl[3])
  end

  -- Move cursor to the current exercise row
  if win and vim.api.nvim_win_is_valid(win) then
    for lnum, ex_idx in pairs(line_to_exercise) do
      if ex_idx == current_index then
        pcall(vim.api.nvim_win_set_cursor, win, { lnum + 1, 0 })
        break
      end
    end
  end
end

--- Open the index sidebar window
---@param on_select function|nil Called with exercise index (1-based) when user selects
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
      if cb then cb() end
    end,
  })

  render(progress.get_exercise_index(), progress.get_all_exercise_counts(), progress.get_required_reps())

  local function select_exercise()
    local cursor_line = vim.api.nvim_win_get_cursor(win)[1] - 1
    local ex_idx = line_to_exercise[cursor_line]
    if ex_idx and on_select then
      pending_on_close = nil  -- selecting: don't fire on_close
      M.close()
      on_select(ex_idx)
    end
  end

  local opts = { buffer = buf, nowait = true, silent = true }
  vim.keymap.set("n", "<CR>", select_exercise, opts)
  vim.keymap.set("n", "q", function() M.close() end, opts)
  vim.keymap.set("n", "<Esc>", function() M.close() end, opts)
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
