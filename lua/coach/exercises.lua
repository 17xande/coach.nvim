-- Exercise definitions extracted from the Neovim user manual
-- Each exercise corresponds to a section from the manual.
-- The `action` field must match what track-action.nvim emits.

local M = {}

M.list = {
	{
		id = "02.2",
		title = "Inserting Text",
		help_tag = "02.2",
		actions = {
			{ action = "i", display = "i", desc = "Insert mode" },
		},
	},
	{
		id = "02.3",
		title = "Moving Around",
		help_tag = "02.3",
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
		help_tag = "02.4",
		actions = {
			{ action = "x", display = "x", desc = "Delete char" },
			{ action = "dd", display = "dd", desc = "Delete line" },
			{ action = "J", display = "J", desc = "Join lines" },
		},
	},
	{
		id = "02.5",
		title = "Undo and Redo",
		help_tag = "02.5",
		actions = {
			{ action = "u", display = "u", desc = "Undo" },
			{ action = "<C-r>", display = "Ctrl-R", desc = "Redo" },
			{ action = "U", display = "U", desc = "Undo line" },
		},
	},
	{
		id = "02.6",
		title = "Other Editing Commands",
		help_tag = "02.6",
		actions = {
			{ action = "a", display = "a", desc = "Append" },
			{ action = "o", display = "o", desc = "Open below" },
			{ action = "O", display = "O", desc = "Open above" },
		},
	},
	{
		id = "02.8",
		title = "Finding Help",
		help_tag = "02.8",
		actions = {
			{ action = "<C-]>", display = "Ctrl-]", desc = "Jump to tag" },
			{ action = "<C-t>", display = "Ctrl-T", desc = "Pop tag" },
			{ action = "<C-o>", display = "Ctrl-O", desc = "Jump back" },
		},
	},

	-- Chapter 03: Moving around

	{
		id = "03.1",
		title = "Word Movement",
		help_tag = "03.1",
		actions = {
			{ action = "w", display = "w", desc = "Word forward" },
			{ action = "b", display = "b", desc = "Word backward" },
			{ action = "e", display = "e", desc = "Word end" },
			{ action = "ge", display = "ge", desc = "Prev word end" },
		},
	},
	{
		id = "03.1W",
		title = "WORD Movement",
		help_tag = "03.1",
		actions = {
			{ action = "W", display = "W", desc = "WORD forward" },
			{ action = "B", display = "B", desc = "WORD backward" },
			{ action = "E", display = "E", desc = "WORD end" },
			{ action = "gE", display = "gE", desc = "Prev WORD end" },
		},
	},
	{
		id = "03.2",
		title = "Line Start/End",
		help_tag = "03.2",
		actions = {
			{ action = "0", display = "0", desc = "Line start" },
			{ action = "^", display = "^", desc = "First non-blank" },
			{ action = "$", display = "$", desc = "Line end" },
		},
	},
	{
		id = "03.3",
		title = "Find Character",
		help_tag = "03.3",
		actions = {
			{ action = "f", display = "f{c}", desc = "Find forward" },
			{ action = "F", display = "F{c}", desc = "Find backward" },
			{ action = "t", display = "t{c}", desc = "Till forward" },
			{ action = "T", display = "T{c}", desc = "Till backward" },
			{ action = ";", display = ";", desc = "Repeat find" },
			{ action = ",", display = ",", desc = "Repeat reverse" },
		},
	},
	{
		id = "03.4",
		title = "Match Paren",
		help_tag = "03.4",
		actions = {
			{ action = "%", display = "%", desc = "Match bracket" },
		},
	},
	{
		id = "03.5",
		title = "Go to Line",
		help_tag = "03.5",
		actions = {
			{ action = "gg", display = "gg", desc = "First line" },
			{ action = "G", display = "G", desc = "Last line" },
			{ action = "H", display = "H", desc = "Screen top" },
			{ action = "M", display = "M", desc = "Screen middle" },
			{ action = "L", display = "L", desc = "Screen bottom" },
		},
	},
	{
		id = "03.7",
		title = "Scrolling",
		help_tag = "03.7",
		actions = {
			{ action = "<C-u>", display = "Ctrl-U", desc = "Half page up" },
			{ action = "<C-d>", display = "Ctrl-D", desc = "Half page down" },
			{ action = "<C-b>", display = "Ctrl-B", desc = "Page up" },
			{ action = "<C-f>", display = "Ctrl-F", desc = "Page down" },
		},
	},
	{
		id = "03.7z",
		title = "Scroll Position",
		help_tag = "03.7",
		actions = {
			{ action = "<C-e>", display = "Ctrl-E", desc = "Scroll up 1" },
			{ action = "<C-y>", display = "Ctrl-Y", desc = "Scroll down 1" },
			{ action = "zz", display = "zz", desc = "Center cursor" },
			{ action = "zt", display = "zt", desc = "Cursor to top" },
			{ action = "zb", display = "zb", desc = "Cursor to bottom" },
		},
	},
	{
		id = "03.8",
		title = "Simple Searches",
		help_tag = "03.8",
		actions = {
			{ action = "n", display = "n", desc = "Next match" },
			{ action = "N", display = "N", desc = "Prev match" },
			{ action = "*", display = "*", desc = "Search word fwd" },
			{ action = "#", display = "#", desc = "Search word bwd" },
		},
	},
	{
		id = "03.10",
		title = "Marks and Jumps",
		help_tag = "03.10",
		actions = {
			{ action = "<C-o>", display = "Ctrl-O", desc = "Older jump" },
			{ action = "<C-i>", display = "Ctrl-I", desc = "Newer jump" },
			{ action = "m", display = "m{a-z}", desc = "Set mark" },
			{ action = "`", display = "`{a-z}", desc = "Go to mark" },
		},
	},

	-- Chapter 04: Making small changes

	{
		id = "04.1",
		title = "Operator + Motion",
		help_tag = "04.1",
		actions = {
			{ action = "dw", display = "dw", desc = "Delete word" },
			{ action = "d$", display = "d$", desc = "Delete to EOL" },
		},
	},
	{
		id = "04.2",
		title = "Change Operator",
		help_tag = "04.2",
		actions = {
			{ action = "cc", display = "cc", desc = "Change line" },
			{ action = "C", display = "C", desc = "Change to EOL" },
			{ action = "r", display = "r", desc = "Replace char" },
			{ action = "s", display = "s", desc = "Substitute char" },
		},
	},
	{
		id = "04.2s",
		title = "Delete Shortcuts",
		help_tag = "04.2",
		actions = {
			{ action = "D", display = "D", desc = "Delete to EOL" },
			{ action = "X", display = "X", desc = "Delete char left" },
			{ action = "S", display = "S", desc = "Substitute line" },
		},
	},
	{
		id = "04.3",
		title = "Repeating a Change",
		help_tag = "04.3",
		actions = {
			{ action = ".", display = ".", desc = "Repeat change" },
		},
	},
	{
		id = "04.4",
		title = "Visual Mode",
		help_tag = "04.4",
		actions = {
			{ action = "v", display = "v", desc = "Visual char" },
			{ action = "V", display = "V", desc = "Visual line" },
			{ action = "<C-v>", display = "Ctrl-V", desc = "Visual block" },
		},
	},
	{
		id = "04.5",
		title = "Moving Text",
		help_tag = "04.5",
		actions = {
			{ action = "p", display = "p", desc = "Put after" },
			{ action = "P", display = "P", desc = "Put before" },
		},
	},
	{
		id = "04.6",
		title = "Copying Text",
		help_tag = "04.6",
		actions = {
			{ action = "yy", display = "yy", desc = "Yank line" },
			{ action = "Y", display = "Y", desc = "Yank to EOL" },
		},
	},
	{
		id = "04.8",
		title = "Text Objects",
		help_tag = "04.8",
		actions = {
			{ action = "daw", display = "daw", desc = "Delete a word" },
			{ action = "diw", display = "diw", desc = "Delete inner word" },
			{ action = "cis", display = "cis", desc = "Change inner sent" },
		},
	},
	{
		id = "04.10",
		title = "More Insert/Case",
		help_tag = "04.10",
		actions = {
			{ action = "~", display = "~", desc = "Toggle case" },
			{ action = "I", display = "I", desc = "Insert at line start" },
			{ action = "A", display = "A", desc = "Append at line end" },
		},
	},

	-- Chapter 07: Editing more than one file

	{
		id = "07.3",
		title = "Alternate File",
		help_tag = "07.3",
		actions = {
			{ action = "<C-^>", display = "Ctrl-^", desc = "Alternate file" },
		},
	},

	-- Chapter 08: Splitting windows

	{
		id = "08.4",
		title = "Window Navigation",
		help_tag = "08.4",
		actions = {
			{ action = "<C-w>w", display = "Ctrl-W w", desc = "Next window" },
			{ action = "<C-w>h", display = "Ctrl-W h", desc = "Window left" },
			{ action = "<C-w>j", display = "Ctrl-W j", desc = "Window down" },
			{ action = "<C-w>k", display = "Ctrl-W k", desc = "Window up" },
			{ action = "<C-w>l", display = "Ctrl-W l", desc = "Window right" },
		},
	},
	{
		id = "08.7",
		title = "Diff Navigation",
		help_tag = "08.7",
		actions = {
			{ action = "]c", display = "]c", desc = "Next change" },
			{ action = "[c", display = "[c", desc = "Prev change" },
			{ action = "dp", display = "dp", desc = "Diff put" },
			{ action = "do", display = "do", desc = "Diff obtain" },
		},
	},
	{
		id = "08.9",
		title = "Tab Pages",
		help_tag = "08.9",
		actions = {
			{ action = "gt", display = "gt", desc = "Next tab" },
			{ action = "gT", display = "gT", desc = "Prev tab" },
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
