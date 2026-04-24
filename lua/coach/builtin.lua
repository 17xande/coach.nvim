-- Builtin exercise set: groups the chapters in `coach.exercises_data`
-- into a handful of volumes by Neovim user-manual chapter ranges.

local data = require("coach.exercises_data")

local M = {}

--- Definitions: name + predicate over chapter id prefix.
local volume_defs = {
	{
		name = "01-first-steps",
		title = "The first steps in Vim",
		match = function(id)
			return id:sub(1, 3) == "02."
		end,
	},
	{
		name = "02-moving-around",
		title = "Moving around",
		match = function(id)
			return id:sub(1, 3) == "03."
		end,
	},
	{
		name = "03-making-changes",
		title = "Making small changes",
		match = function(id)
			return id:sub(1, 3) == "04."
		end,
	},
	{
		name = "04-settings-and-files",
		title = "Settings, syntax, files, windows",
		match = function(id)
			local p = id:sub(1, 3)
			return p == "05." or p == "06." or p == "07." or p == "08."
		end,
	},
	{
		name = "05-bigger-changes",
		title = "Bigger changes, recovery, tricks",
		match = function(id)
			local p = id:sub(1, 3)
			return p == "10." or p == "11." or p == "12."
		end,
	},
	{
		name = "06-advanced",
		title = "Advanced: cmdline, finding, formatting, programming",
		match = function(id)
			local n = tonumber(id:match("^(%d+)%."))
			return n ~= nil and n >= 20
		end,
	},
}

--- Build and return the list of builtin volumes.
--- Each volume: { name, title, chapters }.
---@return { name: string, title: string, chapters: table[] }[]
function M.volumes()
	local out = {}
	for _, def in ipairs(volume_defs) do
		local chapters = {}
		for _, ch in ipairs(data.list) do
			if def.match(ch.id) then
				table.insert(chapters, ch)
			end
		end
		if #chapters > 0 then
			table.insert(out, { name = def.name, title = def.title, chapters = chapters })
		end
	end
	return out
end

return M
