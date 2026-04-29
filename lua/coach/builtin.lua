-- Builtin exercise set: loads volume files from the plugin's own
-- top-level `exercises/` directory. Each `*.lua` file there is one volume.

local M = {}

--- Resolve the plugin's `exercises/` directory via the runtimepath.
---@return string|nil
function M.exercises_dir()
	local matches = vim.api.nvim_get_runtime_file("exercises", true)
	for _, path in ipairs(matches) do
		if vim.fn.isdirectory(path) == 1 then
			return path
		end
	end
	return nil
end

return M
