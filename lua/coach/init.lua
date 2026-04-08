-- coach.nvim - Neovim keybinding coach
-- Public API

local exercises = require("coach.exercises")
local progress = require("coach.progress")
local window = require("coach.window")
local tracker = require("coach.tracker")

local M = {}

---@type boolean
local active = false

---@type number|nil
local save_autocmd = nil

---@type string
local next_key = "<leader>kn"

--- Render the current exercise in the window
local function render_current()
  local exercise = exercises.get(progress.get_exercise_index())
  if exercise then
    window.render(exercise, progress.get_counts(), progress.get_required_reps(), next_key)
  end
end

-- Hook for window message timer to re-render after message clears
window._rerender = render_current

--- Start coaching: load progress, register tracker, open window
function M.start()
  if active then
    return
  end

  progress.load()
  tracker.start()
  window.open()
  render_current()
  active = true

  -- Auto-save on exit
  save_autocmd = vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      progress.save()
    end,
  })
end

--- Stop coaching: unregister tracker, close window, save progress
function M.stop()
  if not active then
    return
  end

  tracker.stop()
  window.close()
  progress.save()
  active = false

  if save_autocmd then
    vim.api.nvim_del_autocmd(save_autocmd)
    save_autocmd = nil
  end
end

--- Toggle coaching on/off
function M.toggle()
  if active then
    M.stop()
  else
    M.start()
  end
end

--- Toggle the window without affecting tracking
function M.toggle_window()
  if not active then
    vim.notify("coach.nvim: coaching is not active. Use :CoachStart first.", vim.log.levels.WARN)
    return
  end

  local opened = window.toggle()
  if opened then
    render_current()
  end
end

--- Advance to the next exercise
function M.next_exercise()
  if not active then
    vim.notify("coach.nvim: coaching is not active.", vim.log.levels.WARN)
    return
  end

  if not progress.is_exercise_complete() then
    vim.notify("coach.nvim: complete the current exercise first.", vim.log.levels.INFO)
    return
  end

  if not progress.advance() then
    vim.notify("coach.nvim: you've completed all exercises!", vim.log.levels.INFO)
    return
  end

  render_current()
end

--- Go to the previous exercise
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

--- Reset the current exercise counts
function M.reset_exercise()
  if not active then
    vim.notify("coach.nvim: coaching is not active.", vim.log.levels.WARN)
    return
  end

  progress.reset_current()
  render_current()
  vim.notify("coach.nvim: current exercise reset.", vim.log.levels.INFO)
end

--- Reset all exercise counts and go back to the first exercise
function M.reset_all()
  if not active then
    vim.notify("coach.nvim: coaching is not active.", vim.log.levels.WARN)
    return
  end

  progress.reset_all()
  render_current()
  vim.notify("coach.nvim: all progress reset.", vim.log.levels.INFO)
end

--- Open the help section for the current exercise
function M.help()
  local exercise = exercises.get(progress.get_exercise_index())
  if not exercise or not exercise.help_tag then
    vim.notify("coach.nvim: no help tag for current exercise.", vim.log.levels.INFO)
    return
  end
  vim.cmd("help " .. exercise.help_tag)
end

--- Check if coaching is active
---@return boolean
function M.is_active()
  return active
end

--- Setup the plugin
---@param opts? { required_reps?: number, progress_file?: string, keybinds?: { toggle?: string, window?: string, next?: string } }
function M.setup(opts)
  opts = opts or {}

  progress.configure({
    required_reps = opts.required_reps,
    progress_file = opts.progress_file,
  })

  -- User commands
  vim.api.nvim_create_user_command("CoachStart", function() M.start() end, {})
  vim.api.nvim_create_user_command("CoachStop", function() M.stop() end, {})
  vim.api.nvim_create_user_command("CoachToggle", function() M.toggle() end, {})
  vim.api.nvim_create_user_command("CoachWindow", function() M.toggle_window() end, {})
  vim.api.nvim_create_user_command("CoachNext", function() M.next_exercise() end, {})
  vim.api.nvim_create_user_command("CoachPrev", function() M.prev_exercise() end, {})
  vim.api.nvim_create_user_command("CoachReset", function() M.reset_exercise() end, {})
  vim.api.nvim_create_user_command("CoachResetAll", function() M.reset_all() end, {})
  vim.api.nvim_create_user_command("CoachHelp", function() M.help() end, {})

  -- Keybindings
  local keys = vim.tbl_extend("force", {
    toggle = "<leader>kk",
    window = "<leader>kw",
    next = "<leader>kn",
    prev = "<leader>kp",
    help = "<leader>kh",
  }, opts.keybinds or {})

  next_key = keys.next
  tracker.set_next_key(next_key)

  vim.keymap.set("n", keys.toggle, function() M.toggle() end, { desc = "Coach: toggle" })
  vim.keymap.set("n", keys.window, function() M.toggle_window() end, { desc = "Coach: toggle window" })
  vim.keymap.set("n", keys.next, function() M.next_exercise() end, { desc = "Coach: next exercise" })
  vim.keymap.set("n", keys.prev, function() M.prev_exercise() end, { desc = "Coach: prev exercise" })
  vim.keymap.set("n", keys.help, function() M.help() end, { desc = "Coach: open help section" })
end

return M
