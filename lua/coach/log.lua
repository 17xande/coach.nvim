-- Debug file logger for coach.nvim
-- Enable via setup({ log_file = "/tmp/coach.log" })

local M = {}

---@type file*|nil
local _file = nil

--- Configure logging. Call from coach.setup().
---@param opts { log_file?: string }
function M.setup(opts)
	if _file then
		_file:close()
		_file = nil
	end
	if opts and opts.log_file then
		_file = io.open(opts.log_file, "a")
	end
end

--- Write a debug line. No-op when log_file not configured.
---@param msg string
---@param data any Optional value — will be vim.inspect'd
function M.debug(msg, data)
	if not _file then
		return
	end
	local line = os.date("%H:%M:%S") .. " " .. msg
	if data ~= nil then
		line = line .. " " .. vim.inspect(data)
	end
	_file:write(line .. "\n")
	_file:flush()
end

--- Close the log file handle.
function M.close()
	if _file then
		_file:close()
		_file = nil
	end
end

return M
