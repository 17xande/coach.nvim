-- Runtime sets API.
-- Holds the set list of the currently-active session. `programs.switch` swaps
-- the list via `set_active_list`; all other modules read through this API.

local M = {}

---@type table[]
M.list = {}

--- Replace the active set list (called by programs.lua on session switch).
---@param sets_list table[]
function M.set_active_list(sets_list)
	M.list = sets_list or {}
end

--- Get a set by 1-based index.
---@param index number
---@return table|nil
function M.get(index)
	return M.list[index]
end

--- Number of sets in the active session.
---@return number
function M.count()
	return #M.list
end

return M
