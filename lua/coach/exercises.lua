-- Exercise definitions extracted from the Neovim user manual (usr_02.txt)
-- Each exercise corresponds to a section from the manual.
-- The `action` field must match what track-action.nvim emits.

local M = {}

M.list = {
  {
    id = "02.2",
    title = "Inserting Text",
    actions = {
      { action = "i", display = "i", desc = "Enter Insert mode (before cursor)" },
    },
  },
  {
    id = "02.3",
    title = "Moving Around",
    actions = {
      { action = "h", display = "h", desc = "Move left" },
      { action = "j", display = "j", desc = "Move down" },
      { action = "k", display = "k", desc = "Move up" },
      { action = "l", display = "l", desc = "Move right" },
    },
  },
  {
    id = "02.4",
    title = "Deleting Characters",
    actions = {
      { action = "x", display = "x", desc = "Delete character under cursor" },
      { action = "dd", display = "dd", desc = "Delete entire line" },
      { action = "J", display = "J", desc = "Join lines" },
    },
  },
  {
    id = "02.5",
    title = "Undo and Redo",
    actions = {
      { action = "u", display = "u", desc = "Undo last edit" },
      { action = "<C-r>", display = "Ctrl-R", desc = "Redo" },
      { action = "U", display = "U", desc = "Undo all changes on line" },
    },
  },
  {
    id = "02.6",
    title = "Other Editing Commands",
    actions = {
      { action = "a", display = "a", desc = "Append (insert after cursor)" },
      { action = "o", display = "o", desc = "Open line below" },
      { action = "O", display = "O", desc = "Open line above" },
    },
  },
  {
    id = "02.8",
    title = "Finding Help",
    actions = {
      { action = "<C-]>", display = "Ctrl-]", desc = "Jump to tag" },
      { action = "<C-t>", display = "Ctrl-T", desc = "Pop tag (go back)" },
      { action = "<C-o>", display = "Ctrl-O", desc = "Jump to older position" },
    },
  },
}

--- Get an exercise by its index (1-based)
---@param index number
---@return table|nil
function M.get(index)
  return M.list[index]
end

--- Get total number of exercises
---@return number
function M.count()
  return #M.list
end

return M
