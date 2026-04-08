-- Bridge to track-action.nvim

local exercises = require("coach.exercises")
local progress = require("coach.progress")
local window = require("coach.window")

local M = {}

--- The callback function reference (needed for off_action)
---@type fun(action: string, data: table)|nil
local callback = nil

--- Recent action history for anti-spam (ring buffer of last 3 actions)
local COOLDOWN = 3
---@type string[]
local recent_actions = {}

--- Next keybind string (set from init.lua)
---@type string
local next_key = "<leader>kn"

--- Set the keybind string shown in the completion hint
---@param key string
function M.set_next_key(key)
  next_key = key
end

--- Record an action in the recent history
---@param action string
local function push_recent(action)
  table.insert(recent_actions, action)
  if #recent_actions > COOLDOWN then
    table.remove(recent_actions, 1)
  end
end

--- Check if an action was performed too recently (anti-spam)
---@param action string
---@return boolean true if the action is on cooldown
local function is_on_cooldown(action)
  for _, recent in ipairs(recent_actions) do
    if recent == action then
      return true
    end
  end
  return false
end

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

  -- Track all actions in the recent history for cooldown purposes,
  -- but only process actions that belong to the current exercise.
  if not action_set[action] then
    push_recent(action)
    return
  end

  if progress.is_action_complete(action) then
    push_recent(action)
    return
  end

  -- Anti-spam: don't count if this action appears in the last N actions
  if is_on_cooldown(action) then
    push_recent(action)
    vim.schedule(function()
      if window.is_open() then
        window.set_message("Repeated actions don't count")
        local exercise = exercises.get(progress.get_exercise_index())
        if exercise then
          window.render(exercise, progress.get_counts(), progress.get_required_reps(), next_key)
        end
      end
    end)
    return
  end

  push_recent(action)

  local was_complete = progress.is_exercise_complete()
  progress.increment(action)
  local now_complete = progress.is_exercise_complete()

  -- Update window if open
  vim.schedule(function()
    if window.is_open() then
      local exercise = exercises.get(progress.get_exercise_index())
      if exercise then
        window.render(exercise, progress.get_counts(), progress.get_required_reps(), next_key)
      end
    end

    -- Notify on exercise completion
    if not was_complete and now_complete then
      if not window.is_open() then
        vim.notify(
          "coach.nvim: Exercise complete! Press " .. next_key .. " for next exercise.",
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

  recent_actions = {}
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
  recent_actions = {}
end

--- Check if tracker is active
---@return boolean
function M.is_active()
  return callback ~= nil
end

return M
