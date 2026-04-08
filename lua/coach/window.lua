-- Floating window for displaying exercise progress

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

--- Pending message to display (set externally, cleared after render)
---@type string|nil
local pending_message = nil

--- Timer for clearing the message
---@type uv_timer_t|nil
local message_timer = nil

--- Set a temporary message to show on next render
---@param msg string
function M.set_message(msg)
  pending_message = msg

  if message_timer then
    message_timer:stop()
  end
  message_timer = vim.uv.new_timer()
  message_timer:start(2000, 0, vim.schedule_wrap(function()
    pending_message = nil
    message_timer = nil
    -- Re-render to clear the message (caller must provide a re-render hook)
    if M._rerender then
      M._rerender()
    end
  end))
end

--- Render the window contents
---@param exercise table Exercise definition
---@param counts table<string, number> Action counts
---@param required_reps number
---@param next_key string Keybind for next exercise
function M.render(exercise, counts, required_reps, next_key)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  local bar_width = 6
  local lines = {}
  local highlights = {} -- { line, col_start, col_end, hl_group }

  -- Help tag reference
  if exercise.help_tag then
    local ref = "  :h " .. exercise.help_tag
    table.insert(lines, ref)
    table.insert(highlights, { #lines - 1, 2, #ref, HL_HINT })
    table.insert(lines, "")
  else
    table.insert(lines, "")
  end

  -- Action lines
  local all_complete = true
  for _, a in ipairs(exercise.actions) do
    local count = math.min(counts[a.action] or 0, required_reps)
    local complete = count >= required_reps
    if not complete then
      all_complete = false
    end

    local filled, empty = progress_bar(count, required_reps, bar_width)
    local count_str = string.format("%2d/%d", count, required_reps)
    local tick = complete and " \u{2713}" or ""

    -- Compact: "  h  left     ██░░  5/20"
    local display = string.format("%-7s", a.display)
    local desc = string.format("%-14s", a.desc)
    local line = "  " .. display .. desc .. filled .. empty .. " " .. count_str .. tick

    local line_idx = #lines
    table.insert(lines, line)

    -- Highlights
    local col = 2
    table.insert(highlights, { line_idx, col, col + #display, HL_ACTION })
    col = col + #display
    table.insert(highlights, { line_idx, col, col + #desc, HL_DESC })
    col = col + #desc
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

  -- Completion message
  if all_complete then
    table.insert(lines, "")
    local msg = "  Exercise Complete!"
    table.insert(lines, msg)
    table.insert(highlights, { #lines - 1, 2, #msg, HL_COMPLETE })

    local hint = "  " .. next_key .. "  next exercise"
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
    vim.api.nvim_buf_add_highlight(buf, ns, hl[4], hl[1], hl[2], hl[3])
  end

  -- Update title and resize
  if win and vim.api.nvim_win_is_valid(win) then
    local width = 0
    for _, line in ipairs(lines) do
      if #line > width then
        width = #line
      end
    end
    width = math.max(width + 2, 34)

    local title = " " .. exercise.title .. " (" .. exercise.id .. ") "
    vim.api.nvim_win_set_config(win, {
      width = width,
      height = #lines,
      title = { { title, "CoachTitle" } },
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

  local editor_width = vim.o.columns
  local win_width = 34
  local win_height = 8

  local display_title = title and (" " .. title .. " ") or " Coach "

  win = vim.api.nvim_open_win(buf, false, {
    relative = "editor",
    width = win_width,
    height = win_height,
    col = editor_width - win_width - 2,
    row = 1,
    style = "minimal",
    border = "rounded",
    title = { { display_title, "CoachTitle" } },
    title_pos = "center",
    focusable = false,
    noautocmd = true,
  })

  vim.api.nvim_set_option_value(
    "winhighlight",
    "Normal:CoachNormal,FloatBorder:CoachBorder",
    { win = win }
  )
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
