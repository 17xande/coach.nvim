-- Session: Moving around (Neovim user-manual chapter 03).

return {
	{
		id = "03.1",
		title = "Word Movement",
		help_tag = "03.1",
		exercises = {
			{ exercise = "w", display = "w", desc = "Word forward" },
			{ exercise = "b", display = "b", desc = "Word backward" },
			{ exercise = "e", display = "e", desc = "Word end" },
			{ exercise = "ge", display = "ge", desc = "Prev word end" },
		},
	},
	{
		id = "03.1W",
		title = "WORD Movement",
		help_tag = "03.1",
		exercises = {
			{ exercise = "W", display = "W", desc = "WORD forward" },
			{ exercise = "B", display = "B", desc = "WORD backward" },
			{ exercise = "E", display = "E", desc = "WORD end" },
			{ exercise = "gE", display = "gE", desc = "Prev WORD end" },
		},
	},
	{
		id = "03.2",
		title = "Line Start/End",
		help_tag = "03.2",
		exercises = {
			{ exercise = "0", display = "0", desc = "Line start" },
			{ exercise = "^", display = "^", desc = "First non-blank" },
			{ exercise = "$", display = "$", desc = "Line end" },
		},
	},
	{
		id = "03.3",
		title = "Find Character",
		help_tag = "03.3",
		exercises = {
			{ exercise = "f", display = "f{c}", desc = "Find forward" },
			{ exercise = "F", display = "F{c}", desc = "Find backward" },
			{ exercise = "t", display = "t{c}", desc = "Till forward" },
			{ exercise = "T", display = "T{c}", desc = "Till backward" },
			{ exercise = ";", display = ";", desc = "Repeat find" },
			{ exercise = ",", display = ",", desc = "Repeat reverse" },
		},
	},
	{
		id = "03.4",
		title = "Match Paren",
		help_tag = "03.4",
		exercises = {
			{ exercise = "%", display = "%", desc = "Match bracket" },
		},
	},
	{
		id = "03.5",
		title = "Go to Line",
		help_tag = "03.5",
		exercises = {
			{ exercise = "gg", display = "gg", desc = "First line" },
			{ exercise = "G", display = "G", desc = "Last line" },
			{ exercise = "H", display = "H", desc = "Screen top" },
			{ exercise = "M", display = "M", desc = "Screen middle" },
			{ exercise = "L", display = "L", desc = "Screen bottom" },
		},
	},
	{
		id = "03.6",
		title = "File Info",
		help_tag = "03.6",
		exercises = {
			{ exercise = "<C-g>", display = "Ctrl-G", desc = "Show file info" },
		},
	},
	{
		id = "03.7",
		title = "Scrolling",
		help_tag = "03.7",
		exercises = {
			{ exercise = "<C-u>", display = "Ctrl-U", desc = "Half page up" },
			{ exercise = "<C-d>", display = "Ctrl-D", desc = "Half page down" },
			{ exercise = "<C-b>", display = "Ctrl-B", desc = "Page up" },
			{ exercise = "<C-f>", display = "Ctrl-F", desc = "Page down" },
		},
	},
	{
		id = "03.7z",
		title = "Scroll Position",
		help_tag = "03.7",
		exercises = {
			{ exercise = "<C-e>", display = "Ctrl-E", desc = "Scroll up 1" },
			{ exercise = "<C-y>", display = "Ctrl-Y", desc = "Scroll down 1" },
			{ exercise = "zz", display = "zz", desc = "Center cursor" },
			{ exercise = "zt", display = "zt", desc = "Cursor to top" },
			{ exercise = "zb", display = "zb", desc = "Cursor to bottom" },
		},
	},
	{
		id = "03.8",
		title = "Simple Searches",
		help_tag = "03.8",
		exercises = {
			{ exercise = "/", display = "/", desc = "Search forward" },
			{ exercise = "?", display = "?", desc = "Search backward" },
			{ exercise = "n", display = "n", desc = "Next match" },
			{ exercise = "N", display = "N", desc = "Prev match" },
			{ exercise = "*", display = "*", desc = "Search word fwd" },
			{ exercise = "#", display = "#", desc = "Search word bwd" },
			{ exercise = "g*", display = "g*", desc = "Search partial word fwd" },
			{ exercise = "g#", display = "g#", desc = "Search partial word bwd" },
			{ exercise = "ex:nohlsearch", display = ":nohlsearch", desc = "Clear highlights" },
		},
	},
	{
		id = "03.10",
		title = "Marks and Jumps",
		help_tag = "03.10",
		exercises = {
			{ exercise = "<C-o>", display = "Ctrl-O", desc = "Older jump" },
			{ exercise = "<C-i>", display = "Ctrl-I", desc = "Newer jump" },
			{ exercise = "m", display = "m{a-z}", desc = "Set mark" },
			{ exercise = "`", display = "`{a-z}", desc = "Go to mark" },
			{ exercise = "''", display = "''", desc = "Jump back to line" },
			{ exercise = "ex:jumps", display = ":jumps", desc = "List jump list" },
			{ exercise = "ex:marks", display = ":marks", desc = "List all marks" },
		},
	},
}
