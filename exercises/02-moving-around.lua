-- Volume: Moving around (Neovim user-manual chapter 03).

return {
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
		id = "03.6",
		title = "File Info",
		help_tag = "03.6",
		actions = {
			{ action = "<C-g>", display = "Ctrl-G", desc = "Show file info" },
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
			{ action = "/", display = "/", desc = "Search forward" },
			{ action = "?", display = "?", desc = "Search backward" },
			{ action = "n", display = "n", desc = "Next match" },
			{ action = "N", display = "N", desc = "Prev match" },
			{ action = "*", display = "*", desc = "Search word fwd" },
			{ action = "#", display = "#", desc = "Search word bwd" },
			{ action = "g*", display = "g*", desc = "Search partial word fwd" },
			{ action = "g#", display = "g#", desc = "Search partial word bwd" },
			{ action = "ex:nohlsearch", display = ":nohlsearch", desc = "Clear highlights" },
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
			{ action = "''", display = "''", desc = "Jump back to line" },
			{ action = "ex:jumps", display = ":jumps", desc = "List jump list" },
			{ action = "ex:marks", display = ":marks", desc = "List all marks" },
		},
	},
}
