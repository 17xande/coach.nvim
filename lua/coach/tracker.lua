-- Bridge to track-action.nvim

local exercises = require("coach.exercises")
local progress = require("coach.progress")
local window = require("coach.window")

local M = {}

--- The callback function reference (needed for off_action)
---@type fun(action: string, data: table)|nil
local callback = nil

--- Build a lookup set of actions for the current exercise
---@return table<string, boolean>
local function current_action_set()
  local exercise = exercises.get(progress.get_exercise_index())
  if not exercise then
    return {}
  end

  local set = {}
  for _, a in ipairs(exercise.actions) do
    set[a.action] = true
  end
  return set
end

--- Handle an action from track-action.nvim
---@param action string
---@param _data table
local function on_action(action, _data)
  local action_set = current_action_set()
  if not action_set[action] then
    return
  end

  if progress.is_action_complete(action) then
    return
  end

  local was_complete = progress.is_exercise_complete()
  progress.increment(action)
  local now_complete = progress.is_exercise_complete()

  -- Update window if open
  vim.schedule(function()
    if window.is_open() then
      local exercise = exercises.get(progress.get_exercise_index())
      if exercise then
        window.render(exercise, progress.get_counts(), progress.get_required_reps())
      end
    end

    -- Notify on exercise completion
    if not was_complete and now_complete then
      if not window.is_open() then
        vim.notify(
          "coach.nvim: Exercise complete! Press <leader>cn for next exercise.",
          vim.log.levels.INFO
        )
      end
      progress.save()
    end
  end)
end

--- Start tracking by registering callback with track-action.nvim
function M.start()
  if callback then
    return
  end

  local ok, track_action = pcall(require, "track-action")
  if not ok then
    vim.notify("coach.nvim: track-action.nvim is required but not found", vim.log.levels.ERROR)
    return
  end

  callback = on_action
  track_action.on_action(callback)
end

--- Stop tracking by unregistering callback
function M.stop()
  if not callback then
    return
  end

  local ok, track_action = pcall(require, "track-action")
  if ok then
    track_action.off_action(callback)
  end

  callback = nil
end

--- Check if tracker is active
---@return boolean
function M.is_active()
  return callback ~= nil
end

return M
