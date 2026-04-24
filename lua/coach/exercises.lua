-- Runtime exercise API.
-- Holds the chapter list of the currently-active volume. `sets.switch` swaps
-- the list via `set_active_chapters`; all other modules read through this API.

local M = {}

---@type table[]
M.list = {}

--- Replace the active chapter list (called by sets.lua on volume switch).
---@param chapters table[]
function M.set_active_chapters(chapters)
	M.list = chapters or {}
end

--- Get a chapter by 1-based index.
---@param index number
---@return table|nil
function M.get(index)
	return M.list[index]
end

--- Number of chapters in the active volume.
---@return number
function M.count()
	return #M.list
end

return M
