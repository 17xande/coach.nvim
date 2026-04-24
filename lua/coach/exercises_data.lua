-- Exercise definitions extracted from the Neovim user manual
-- Each exercise corresponds to a section from the manual.
-- The `action` field must match what track-action.nvim emits.

local M = {}

M.list = {
	-- Chapter 02: The first steps in Vim

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
		id = "02.7",
		title = "Save and Quit",
		help_tag = "02.7",
		actions = {
			{ action = "ZZ", display = "ZZ", desc = "Save and quit" },
			{ action = "ex:q", display = ":q", desc = "Quit" },
			{ action = "ex:q!", display = ":q!", desc = "Quit without saving" },
			{ action = "ex:e!", display = ":e!", desc = "Reload file" },
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
			{ action = "ex:help", display = ":help", desc = "Open help" },
			{ action = "ex:helpgrep", display = ":helpgrep", desc = "Search all help" },
			{ action = "ex:cnext", display = ":cnext", desc = "Next quickfix result" },
			{ action = "ex:copen", display = ":copen", desc = "Open quickfix window" },
			{ action = "ex:Tutor", display = ":Tutor", desc = "Open Vim tutorial" },
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
			{ action = "das", display = "das", desc = "Delete a sentence" },
		},
	},
	{
		id = "04.9",
		title = "Replace Mode",
		help_tag = "04.9",
		actions = {
			{ action = "R", display = "R", desc = "Replace mode" },
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

	-- Chapter 05: Set your settings

	{
		id = "05.1",
		title = "Edit vimrc",
		help_tag = "05.1",
		actions = {
			{ action = "ex:edit", display = ":edit", desc = "Edit file" },
		},
	},
	{
		id = "05.3",
		title = "Mappings",
		help_tag = "05.3",
		actions = {
			{ action = "ex:map", display = ":map", desc = "Create/list mappings" },
		},
	},
	{
		id = "05.4",
		title = "Packages",
		help_tag = "05.4",
		actions = {
			{ action = "ex:packadd", display = ":packadd", desc = "Load package" },
		},
	},
	{
		id = "05.6",
		title = "Help Files",
		help_tag = "05.6",
		actions = {
			{ action = "ex:helptags", display = ":helptags", desc = "Generate help tags" },
		},
	},
	{
		id = "05.7",
		title = "Option Window",
		help_tag = "05.7",
		actions = {
			{ action = "ex:options", display = ":options", desc = "Option window" },
		},
	},

	-- Chapter 06: Syntax highlighting

	{
		id = "06.2",
		title = "Redraw Screen",
		help_tag = "06.2",
		actions = {
			{ action = "<C-l>", display = "Ctrl-L", desc = "Redraw screen" },
		},
	},
	{
		id = "06.3",
		title = "Colorscheme",
		help_tag = "06.3",
		actions = {
			{ action = "ex:colorscheme", display = ":colorscheme", desc = "Apply colorscheme" },
		},
	},
	{
		id = "06.4",
		title = "Toggle Syntax",
		help_tag = "06.4",
		actions = {
			{ action = "ex:syntax", display = ":syntax", desc = "Toggle syntax" },
		},
	},

	-- Chapter 07: Editing more than one file

	{
		id = "07.1",
		title = "File Operations",
		help_tag = "07.1",
		actions = {
			{ action = "ex:edit", display = ":edit", desc = "Open file" },
			{ action = "ex:write", display = ":write", desc = "Save file" },
			{ action = "ex:hide", display = ":hide", desc = "Hide buffer, switch file" },
		},
	},
	{
		id = "07.2",
		title = "Argument List",
		help_tag = "07.2",
		actions = {
			{ action = "ex:next", display = ":next", desc = "Next file" },
			{ action = "ex:previous", display = ":previous", desc = "Previous file" },
			{ action = "ex:first", display = ":first", desc = "First file" },
			{ action = "ex:last", display = ":last", desc = "Last file" },
			{ action = "ex:args", display = ":args", desc = "Show arg list" },
			{ action = "ex:wnext", display = ":wnext", desc = "Write, then next file" },
			{ action = "ex:wprevious", display = ":wprevious", desc = "Write, then prev file" },
		},
	},
	{
		id = "07.3",
		title = "Alternate File",
		help_tag = "07.3",
		actions = {
			{ action = "<C-^>", display = "Ctrl-^", desc = "Alternate file" },
			{ action = "`\"", display = "`\"", desc = "Pos when last left file" },
			{ action = "`.", display = "`.", desc = "Pos of last change" },
		},
	},
	{
		id = "07.7",
		title = "Rename/Save As",
		help_tag = "07.7",
		actions = {
			{ action = "ex:saveas", display = ":saveas", desc = "Save as new file" },
			{ action = "ex:file", display = ":file", desc = "Rename buffer" },
		},
	},

	-- Chapter 08: Splitting windows

	{
		id = "08.1",
		title = "Split Windows",
		help_tag = "08.1",
		actions = {
			{ action = "ex:split", display = ":split", desc = "Horizontal split" },
			{ action = "ex:close", display = ":close", desc = "Close window" },
			{ action = "ex:only", display = ":only", desc = "Keep only current" },
			{ action = "ex:new", display = ":new", desc = "New empty split" },
		},
	},
	{
		id = "08.3",
		title = "Window Size",
		help_tag = "08.3",
		actions = {
			{ action = "<C-w>+", display = "Ctrl-W +", desc = "Increase height" },
			{ action = "<C-w>-", display = "Ctrl-W -", desc = "Decrease height" },
			{ action = "<C-w>_", display = "Ctrl-W _", desc = "Max height" },
			{ action = "<C-w>=", display = "Ctrl-W =", desc = "Equal sizes" },
		},
	},
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
			{ action = "<C-w>t", display = "Ctrl-W t", desc = "Top window" },
			{ action = "<C-w>b", display = "Ctrl-W b", desc = "Bottom window" },
		},
	},
	{
		id = "08.4v",
		title = "Vertical Splits",
		help_tag = "08.4",
		actions = {
			{ action = "ex:vsplit", display = ":vsplit", desc = "Vertical split" },
			{ action = "ex:vnew", display = ":vnew", desc = "Vertical new buffer" },
			{ action = "ex:vertical", display = ":vertical", desc = "Force vertical modifier" },
		},
	},
	{
		id = "08.5",
		title = "Moving Windows",
		help_tag = "08.5",
		actions = {
			{ action = "<C-w>K", display = "Ctrl-W K", desc = "Move to top" },
			{ action = "<C-w>J", display = "Ctrl-W J", desc = "Move to bottom" },
			{ action = "<C-w>H", display = "Ctrl-W H", desc = "Move to far left" },
			{ action = "<C-w>L", display = "Ctrl-W L", desc = "Move to far right" },
		},
	},
	{
		id = "08.6",
		title = "All Windows",
		help_tag = "08.6",
		actions = {
			{ action = "ex:qall", display = ":qall", desc = "Quit all" },
			{ action = "ex:wall", display = ":wall", desc = "Write all" },
			{ action = "ex:wqall", display = ":wqall", desc = "Write and quit all" },
			{ action = "ex:all", display = ":all", desc = "Open window for each arg" },
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
			{ action = "ex:diffsplit", display = ":diffsplit", desc = "Diff split with file" },
			{ action = "ex:diffpatch", display = ":diffpatch", desc = "Diff apply patch" },
			{ action = "ex:diffupdate", display = ":diffupdate", desc = "Refresh diff" },
		},
	},
	{
		id = "08.9",
		title = "Tab Pages",
		help_tag = "08.9",
		actions = {
			{ action = "gt", display = "gt", desc = "Next tab" },
			{ action = "gT", display = "gT", desc = "Prev tab" },
			{ action = "ex:tabedit", display = ":tabedit", desc = "Open in new tab" },
			{ action = "ex:tab", display = ":tab split", desc = "Dup current in new tab" },
			{ action = "ex:tabonly", display = ":tabonly", desc = "Close other tabs" },
		},
	},

	-- Chapter 10: Making big changes

	{
		id = "10.1",
		title = "Macros",
		help_tag = "10.1",
		actions = {
			{ action = "q", display = "q{a-z}", desc = "Record macro" },
			{ action = "@", display = "@{a-z}", desc = "Replay macro" },
			{ action = "@@", display = "@@", desc = "Replay last macro" },
		},
	},
	{
		id = "10.2",
		title = "Substitution",
		help_tag = "10.2",
		actions = {
			{ action = "ex:substitute", display = ":s", desc = "Substitute" },
		},
	},
	{
		id = "10.4",
		title = "Global Command",
		help_tag = "10.4",
		actions = {
			{ action = "ex:global", display = ":g", desc = "Global command" },
		},
	},
	{
		id = "10.6",
		title = "Read/Write Files",
		help_tag = "10.6",
		actions = {
			{ action = "ex:read", display = ":read", desc = "Insert file below cursor" },
		},
	},
	{
		id = "10.7",
		title = "Format Text",
		help_tag = "10.7",
		actions = {
			{ action = "gqap", display = "gqap", desc = "Format paragraph" },
			{ action = "gqq", display = "gqq", desc = "Format line" },
			{ action = "gq]/", display = "gq]/", desc = "Format C comment" },
		},
	},
	{
		id = "10.8",
		title = "Change Case",
		help_tag = "10.8",
		actions = {
			{ action = "gUU", display = "gUU", desc = "Uppercase line" },
			{ action = "guu", display = "guu", desc = "Lowercase line" },
			{ action = "g~~", display = "g~~", desc = "Swap case line" },
			{ action = "gUw", display = "gUw", desc = "Uppercase word" },
			{ action = "guw", display = "guw", desc = "Lowercase word" },
		},
	},
	{
		id = "10.9",
		title = "External Programs",
		help_tag = "10.9",
		actions = {
			{ action = "!!", display = "!!", desc = "Filter line through program" },
			{ action = "ex:!", display = ":!{cmd}", desc = "Execute shell command" },
		},
	},

	-- Chapter 11: Recovering from a crash

	{
		id = "11.1",
		title = "Recovery",
		help_tag = "11.1",
		actions = {
			{ action = "ex:recover", display = ":recover", desc = "Recover from swap file" },
		},
	},

	-- Chapter 12: Clever tricks

	{
		id = "12.6",
		title = "Man Page Lookup",
		help_tag = "12.6",
		actions = {
			{ action = "K", display = "K", desc = "Lookup man page" },
			{ action = "g<C-g>", display = "g Ctrl-G", desc = "Count words/lines/bytes" },
			{ action = "ex:Man", display = ":Man", desc = "Open man page in split" },
		},
	},
	{
		id = "12.8",
		title = "Grep and Quickfix",
		help_tag = "12.8",
		actions = {
			{ action = "ex:grep", display = ":grep", desc = "Search files" },
			{ action = "ex:cnext", display = ":cnext", desc = "Next quickfix" },
			{ action = "ex:cprev", display = ":cprev", desc = "Prev quickfix" },
			{ action = "ex:clist", display = ":clist", desc = "List quickfix" },
		},
	},

	-- Chapter 20: Typing command-line commands quickly

	{
		id = "20.4",
		title = "Command History",
		help_tag = "20.4",
		actions = {
			{ action = "q:", display = "q:", desc = "Open cmdline history window" },
			{ action = "q/", display = "q/", desc = "Open search history window" },
			{ action = "ex:history", display = ":history", desc = "Show command history" },
		},
	},

	-- Chapter 21: Go away and come back

	{
		id = "21.1",
		title = "Suspend Vim",
		help_tag = "21.1",
		actions = {
			{ action = "<C-z>", display = "Ctrl-Z", desc = "Suspend Vim" },
			{ action = "ex:suspend", display = ":suspend", desc = "Suspend command" },
		},
	},
	{
		id = "21.2",
		title = "Terminal",
		help_tag = "21.2",
		actions = {
			{ action = "ex:terminal", display = ":terminal", desc = "Open terminal" },
			{ action = "ex:!", display = ":!{cmd}", desc = "Execute shell command" },
		},
	},
	{
		id = "21.3",
		title = "Old Files",
		help_tag = "21.3",
		actions = {
			{ action = "ex:oldfiles", display = ":oldfiles", desc = "List recent files" },
			{ action = "'0", display = "'0", desc = "Pos on last Vim exit" },
			{ action = "ex:browse", display = ":browse oldfiles", desc = "Browse recent files" },
			{ action = "ex:wshada", display = ":wshada", desc = "Write ShaDa file" },
			{ action = "ex:rshada", display = ":rshada", desc = "Read ShaDa file" },
		},
	},
	{
		id = "21.4",
		title = "Sessions",
		help_tag = "21.4",
		actions = {
			{ action = "ex:mksession", display = ":mksession", desc = "Save session" },
			{ action = "ex:source", display = ":source", desc = "Load script/session" },
		},
	},
	{
		id = "21.5",
		title = "Views",
		help_tag = "21.5",
		actions = {
			{ action = "ex:mkview", display = ":mkview", desc = "Save window view" },
			{ action = "ex:loadview", display = ":loadview", desc = "Restore window view" },
		},
	},

	-- Chapter 22: Finding the file to edit

	{
		id = "22.1",
		title = "File Browser",
		help_tag = "22.1",
		actions = {
			{ action = "ex:Explore", display = ":Explore", desc = "Browse directory" },
		},
	},
	{
		id = "22.2",
		title = "Current Directory",
		help_tag = "22.2",
		actions = {
			{ action = "ex:cd", display = ":cd", desc = "Change directory" },
			{ action = "ex:pwd", display = ":pwd", desc = "Show directory" },
			{ action = "ex:lcd", display = ":lcd", desc = "Window-local cd" },
			{ action = "ex:tcd", display = ":tcd", desc = "Tab-local cd" },
		},
	},
	{
		id = "22.3",
		title = "File Under Cursor",
		help_tag = "22.3",
		actions = {
			{ action = "gf", display = "gf", desc = "Go to file" },
			{ action = "<C-w>f", display = "Ctrl-W f", desc = "Open in split" },
			{ action = "ex:find", display = ":find", desc = "Find in path" },
			{ action = "ex:sfind", display = ":sfind", desc = "Find in path, split" },
		},
	},
	{
		id = "22.4",
		title = "Buffer List",
		help_tag = "22.4",
		actions = {
			{ action = "ex:buffers", display = ":buffers", desc = "List buffers" },
			{ action = "ex:buffer", display = ":buffer", desc = "Switch to buffer" },
			{ action = "ex:sbuffer", display = ":sbuffer", desc = "Open buffer in split" },
			{ action = "ex:bnext", display = ":bnext", desc = "Next buffer" },
			{ action = "ex:bprevious", display = ":bprevious", desc = "Prev buffer" },
			{ action = "ex:bfirst", display = ":bfirst", desc = "First buffer" },
			{ action = "ex:blast", display = ":blast", desc = "Last buffer" },
			{ action = "ex:bdelete", display = ":bdelete", desc = "Delete buffer" },
			{ action = "ex:bwipe", display = ":bwipe", desc = "Remove buffer completely" },
		},
	},

	-- Chapter 23: Editing other files

	{
		id = "23.3",
		title = "Character Values",
		help_tag = "23.3",
		actions = {
			{ action = "ga", display = "ga", desc = "Show char value" },
			{ action = "go", display = "{N}go", desc = "Go to byte N" },
		},
	},

	-- Chapter 24: Inserting quickly

	{
		id = "24.7",
		title = "Abbreviations",
		help_tag = "24.7",
		actions = {
			{ action = "ex:abbreviate", display = ":abbreviate", desc = "List abbreviations" },
			{ action = "ex:unabbreviate", display = ":unabbreviate", desc = "Remove abbreviation" },
			{ action = "ex:abclear", display = ":abclear", desc = "Clear all abbreviations" },
		},
	},
	{
		id = "24.9",
		title = "Digraphs",
		help_tag = "24.9",
		actions = {
			{ action = "ex:digraphs", display = ":digraphs", desc = "Show digraph table" },
		},
	},

	-- Chapter 25: Editing formatted text

	{
		id = "25.2",
		title = "Text Alignment",
		help_tag = "25.2",
		actions = {
			{ action = "ex:center", display = ":center", desc = "Center lines" },
			{ action = "ex:right", display = ":right", desc = "Right-justify lines" },
			{ action = "ex:left", display = ":left", desc = "Left-align lines" },
		},
	},
	{
		id = "25.3",
		title = "Indent/Unindent",
		help_tag = "25.3",
		actions = {
			{ action = ">>", display = ">>", desc = "Indent line" },
			{ action = "<<", display = "<<", desc = "Unindent line" },
			{ action = "ex:retab", display = ":retab", desc = "Convert indentation" },
		},
	},
	{
		id = "25.4g",
		title = "Screen Line Movement",
		help_tag = "25.4",
		actions = {
			{ action = "g0", display = "g0", desc = "Visible line start" },
			{ action = "g^", display = "g^", desc = "Visible first non-blank" },
			{ action = "gm", display = "gm", desc = "Middle of screen line" },
			{ action = "g$", display = "g$", desc = "Visible line end" },
			{ action = "gj", display = "gj", desc = "Screen line down" },
			{ action = "gk", display = "gk", desc = "Screen line up" },
		},
	},
	{
		id = "25.4h",
		title = "Horizontal Scroll",
		help_tag = "25.4",
		actions = {
			{ action = "zh", display = "zh", desc = "Scroll right 1" },
			{ action = "zl", display = "zl", desc = "Scroll left 1" },
			{ action = "zH", display = "zH", desc = "Scroll right half" },
			{ action = "zL", display = "zL", desc = "Scroll left half" },
			{ action = "zs", display = "zs", desc = "Cursor to screen start" },
			{ action = "ze", display = "ze", desc = "Cursor to screen end" },
		},
	},
	{
		id = "25.5",
		title = "Virtual Replace",
		help_tag = "25.5",
		actions = {
			{ action = "gr", display = "gr{c}", desc = "Virtual replace char" },
			{ action = "gR", display = "gR", desc = "Virtual replace mode" },
		},
	},

	-- Chapter 26: Repeating

	{
		id = "26.1",
		title = "Reselect Visual",
		help_tag = "26.1",
		actions = {
			{ action = "gv", display = "gv", desc = "Reselect visual" },
		},
	},
	{
		id = "26.2",
		title = "Increment / Decrement",
		help_tag = "26.2",
		actions = {
			{ action = "<C-a>", display = "Ctrl-A", desc = "Increment number" },
			{ action = "<C-x>", display = "Ctrl-X", desc = "Decrement number" },
		},
	},
	{
		id = "26.3",
		title = "Batch Commands",
		help_tag = "26.3",
		actions = {
			{ action = "ex:argdo", display = ":argdo", desc = "Do on all args" },
			{ action = "ex:windo", display = ":windo", desc = "Do on all windows" },
			{ action = "ex:bufdo", display = ":bufdo", desc = "Do on all buffers" },
		},
	},

	-- Chapter 28: Folding

	{
		id = "28.2",
		title = "Folding",
		help_tag = "28.2",
		actions = {
			{ action = "zf", display = "zf{motion}", desc = "Create fold" },
			{ action = "zo", display = "zo", desc = "Open fold" },
			{ action = "zc", display = "zc", desc = "Close fold" },
			{ action = "zO", display = "zO", desc = "Open recursive" },
			{ action = "zC", display = "zC", desc = "Close recursive" },
			{ action = "zr", display = "zr", desc = "Reduce fold level" },
			{ action = "zm", display = "zm", desc = "More folding" },
			{ action = "zR", display = "zR", desc = "Open all" },
			{ action = "zM", display = "zM", desc = "Close all" },
			{ action = "zi", display = "zi", desc = "Toggle folding" },
			{ action = "zn", display = "zn", desc = "Disable folding" },
			{ action = "zN", display = "zN", desc = "Re-enable folding" },
			{ action = "zd", display = "zd", desc = "Delete fold" },
			{ action = "zD", display = "zD", desc = "Delete folds recursive" },
		},
	},

	-- Chapter 29: Moving through programs

	{
		id = "29.1",
		title = "Tag Navigation",
		help_tag = "29.1",
		actions = {
			{ action = "<C-w>]", display = "Ctrl-W ]", desc = "Split and jump to tag" },
			{ action = "ex:tag", display = ":tag", desc = "Jump to tag" },
			{ action = "ex:tags", display = ":tags", desc = "Show tag stack" },
			{ action = "ex:stag", display = ":stag", desc = "Split and jump to tag" },
			{ action = "ex:tnext", display = ":tnext", desc = "Next tag match" },
			{ action = "ex:tprevious", display = ":tprevious", desc = "Prev tag match" },
			{ action = "ex:tselect", display = ":tselect", desc = "Select from tag matches" },
		},
	},
	{
		id = "29.2",
		title = "Preview Window",
		help_tag = "29.2",
		actions = {
			{ action = "<C-w>}", display = "Ctrl-W }", desc = "Preview tag" },
			{ action = "ex:ptag", display = ":ptag", desc = "Open preview for tag" },
			{ action = "ex:pclose", display = ":pclose", desc = "Close preview window" },
			{ action = "ex:pedit", display = ":pedit", desc = "Edit in preview window" },
			{ action = "ex:psearch", display = ":psearch", desc = "Search in preview" },
		},
	},
	{
		id = "29.3",
		title = "Code Block Movement",
		help_tag = "29.3",
		actions = {
			{ action = "[[", display = "[[", desc = "Prev outer {" },
			{ action = "]]", display = "]]", desc = "Next function" },
			{ action = "][", display = "][", desc = "End of outer block" },
			{ action = "[]", display = "[]", desc = "Backward to function end" },
			{ action = "[{", display = "[{", desc = "Start of block" },
			{ action = "]}", display = "]}", desc = "End of block" },
			{ action = "[(", display = "[(", desc = "Unclosed ( left" },
			{ action = "])", display = "])", desc = "Unclosed ) right" },
			{ action = "[#", display = "[#", desc = "Unclosed #if" },
			{ action = "]#", display = "]#", desc = "Next #else/#endif" },
			{ action = "[/", display = "[/", desc = "Start of C comment" },
			{ action = "]/", display = "]/", desc = "End of C comment" },
			{ action = "[m", display = "[m", desc = "Prev method start" },
			{ action = "]m", display = "]m", desc = "Next method start" },
		},
	},
	{
		id = "29.4",
		title = "Find Identifiers",
		help_tag = "29.4",
		actions = {
			{ action = "[I", display = "[I", desc = "List all matches for word" },
			{ action = "[i", display = "[i", desc = "Show first match for word" },
			{ action = "[D", display = "[D", desc = "List #define matches" },
			{ action = "[d", display = "[d", desc = "Show first #define match" },
			{ action = "ex:checkpath", display = ":checkpath", desc = "Check include paths" },
		},
	},
	{
		id = "29.5",
		title = "Go to Declaration",
		help_tag = "29.5",
		actions = {
			{ action = "gD", display = "gD", desc = "Global declaration" },
			{ action = "gd", display = "gd", desc = "Local declaration" },
		},
	},

	-- Chapter 30: Editing programs

	{
		id = "30.1",
		title = "Compile and Quickfix",
		help_tag = "30.1",
		actions = {
			{ action = "ex:make", display = ":make", desc = "Run make" },
			{ action = "ex:cnext", display = ":cnext", desc = "Next error" },
			{ action = "ex:cprevious", display = ":cprevious", desc = "Prev error" },
			{ action = "ex:cc", display = ":cc", desc = "Show current error" },
			{ action = "ex:clist", display = ":clist", desc = "List errors" },
			{ action = "ex:cfirst", display = ":cfirst", desc = "First error" },
			{ action = "ex:clast", display = ":clast", desc = "Last error" },
			{ action = "ex:colder", display = ":colder", desc = "Previous error list" },
			{ action = "ex:cnewer", display = ":cnewer", desc = "Next error list" },
			{ action = "ex:compiler", display = ":compiler", desc = "Load compiler settings" },
		},
	},
	{
		id = "30.2",
		title = "Re-indent",
		help_tag = "30.2",
		actions = {
			{ action = "==", display = "==", desc = "Re-indent line" },
			{ action = "=G", display = "=G", desc = "Re-indent to EOF" },
			{ action = "=a{", display = "=a{", desc = "Re-indent {} block" },
			{ action = ">i{", display = ">i{", desc = "Indent inside {} block" },
		},
	},

	-- Chapter 31: Exploiting the GUI

	{
		id = "31.1",
		title = "Browse and Confirm",
		help_tag = "31.1",
		actions = {
			{ action = "ex:browse", display = ":browse edit", desc = "Browse for file" },
			{ action = "ex:confirm", display = ":confirm edit", desc = "Edit with confirmation" },
		},
	},

	-- Chapter 32: Undo tree

	{
		id = "32.3",
		title = "Undo Tree Navigation",
		help_tag = "32.3",
		actions = {
			{ action = "g-", display = "g-", desc = "Older state" },
			{ action = "g+", display = "g+", desc = "Newer state" },
			{ action = "ex:undo", display = ":undo {N}", desc = "Jump to undo state" },
		},
	},
	{
		id = "32.4",
		title = "Time Travel Undo",
		help_tag = "32.4",
		actions = {
			{ action = "ex:earlier", display = ":earlier", desc = "Go back in time" },
			{ action = "ex:later", display = ":later", desc = "Go forward in time" },
			{ action = "ex:undolist", display = ":undolist", desc = "Show undo tree" },
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
