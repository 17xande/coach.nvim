-- Volume: Advanced — cmdline, finding, formatting, programming
-- (Neovim user-manual chapters 20+).

return {
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
