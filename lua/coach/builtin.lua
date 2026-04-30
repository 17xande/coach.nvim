-- Builtin program: loads session files from the plugin's own
-- `exercise-programs/user-manual/` directory. Each `*.lua` file there is one session.

local M = {}

--- Resolve the plugin's `exercise-programs/user-manual/` directory via the runtimepath.
---@return string|nil
function M.default_program_dir()
	local matches = vim.api.nvim_get_runtime_file("exercise-programs/user-manual", true)
	for _, path in ipairs(matches) do
		if vim.fn.isdirectory(path) == 1 then
			return path
		end
	end
	return nil
end

return M
