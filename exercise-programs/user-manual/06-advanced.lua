-- Session: Advanced — cmdline, finding, formatting, programming
-- (Neovim user-manual chapters 20+).

return {
	-- Chapter 20: Typing command-line commands quickly
	{
		id = "20.4",
		title = "Command History",
		help_tag = "20.4",
		exercises = {
			{ exercise = "q:", display = "q:", desc = "Open cmdline history window" },
			{ exercise = "q/", display = "q/", desc = "Open search history window" },
			{ exercise = "ex:history", display = ":history", desc = "Show command history" },
		},
	},

	-- Chapter 21: Go away and come back
	{
		id = "21.1",
		title = "Suspend Vim",
		help_tag = "21.1",
		exercises = {
			{ exercise = "<C-z>", display = "Ctrl-Z", desc = "Suspend Vim" },
			{ exercise = "ex:suspend", display = ":suspend", desc = "Suspend command" },
		},
	},
	{
		id = "21.2",
		title = "Terminal",
		help_tag = "21.2",
		exercises = {
			{ exercise = "ex:terminal", display = ":terminal", desc = "Open terminal" },
			{ exercise = "ex:!", display = ":!{cmd}", desc = "Execute shell command" },
		},
	},
	{
		id = "21.3",
		title = "Old Files",
		help_tag = "21.3",
		exercises = {
			{ exercise = "ex:oldfiles", display = ":oldfiles", desc = "List recent files" },
			-- '0 is the position on last exit, but a mark jump is reported as
			-- '{mark} whichever mark it was, so that is what can be counted.
			{ exercise = "'{mark}", display = "'{mark}", desc = "'0 is pos on last Vim exit" },
			{ exercise = "ex:browse", display = ":browse oldfiles", desc = "Browse recent files" },
			{ exercise = "ex:wshada", display = ":wshada", desc = "Write ShaDa file" },
			{ exercise = "ex:rshada", display = ":rshada", desc = "Read ShaDa file" },
		},
	},
	{
		id = "21.4",
		title = "Sessions",
		help_tag = "21.4",
		exercises = {
			{ exercise = "ex:mksession", display = ":mksession", desc = "Save session" },
			{ exercise = "ex:source", display = ":source", desc = "Load script/session" },
		},
	},
	{
		id = "21.5",
		title = "Views",
		help_tag = "21.5",
		exercises = {
			{ exercise = "ex:mkview", display = ":mkview", desc = "Save window view" },
			{ exercise = "ex:loadview", display = ":loadview", desc = "Restore window view" },
		},
	},

	-- Chapter 22: Finding the file to edit
	{
		id = "22.1",
		title = "File Browser",
		help_tag = "22.1",
		exercises = {
			{ exercise = "ex:Explore", display = ":Explore", desc = "Browse directory" },
		},
	},
	{
		id = "22.2",
		title = "Current Directory",
		help_tag = "22.2",
		exercises = {
			{ exercise = "ex:cd", display = ":cd", desc = "Change directory" },
			{ exercise = "ex:pwd", display = ":pwd", desc = "Show directory" },
			{ exercise = "ex:lcd", display = ":lcd", desc = "Window-local cd" },
			{ exercise = "ex:tcd", display = ":tcd", desc = "Tab-local cd" },
		},
	},
	{
		id = "22.3",
		title = "File Under Cursor",
		help_tag = "22.3",
		exercises = {
			{ exercise = "gf", display = "gf", desc = "Go to file" },
			{ exercise = "<C-w>f", display = "Ctrl-W f", desc = "Open in split" },
			{ exercise = "ex:find", display = ":find", desc = "Find in path" },
			{ exercise = "ex:sfind", display = ":sfind", desc = "Find in path, split" },
		},
	},
	{
		id = "22.4",
		title = "Buffer List",
		help_tag = "22.4",
		exercises = {
			{ exercise = "ex:buffers", display = ":buffers", desc = "List buffers" },
			{ exercise = "ex:buffer", display = ":buffer", desc = "Switch to buffer" },
			{ exercise = "ex:sbuffer", display = ":sbuffer", desc = "Open buffer in split" },
			{ exercise = "ex:bnext", display = ":bnext", desc = "Next buffer" },
			{ exercise = "ex:bprevious", display = ":bprevious", desc = "Prev buffer" },
			{ exercise = "ex:bfirst", display = ":bfirst", desc = "First buffer" },
			{ exercise = "ex:blast", display = ":blast", desc = "Last buffer" },
			{ exercise = "ex:bdelete", display = ":bdelete", desc = "Delete buffer" },
			{ exercise = "ex:bwipe", display = ":bwipe", desc = "Remove buffer completely" },
		},
	},

	-- Chapter 23: Editing other files
	{
		id = "23.3",
		title = "Character Values",
		help_tag = "23.3",
		exercises = {
			{ exercise = "ga", display = "ga", desc = "Show char value" },
			{ exercise = "[count]go", display = "[count]go", desc = "Go to byte N" },
		},
	},

	-- Chapter 24: Inserting quickly
	{
		id = "24.7",
		title = "Abbreviations",
		help_tag = "24.7",
		exercises = {
			{ exercise = "ex:abbreviate", display = ":abbreviate", desc = "List abbreviations" },
			{ exercise = "ex:unabbreviate", display = ":unabbreviate", desc = "Remove abbreviation" },
			{ exercise = "ex:abclear", display = ":abclear", desc = "Clear all abbreviations" },
		},
	},
	{
		id = "24.9",
		title = "Digraphs",
		help_tag = "24.9",
		exercises = {
			{ exercise = "ex:digraphs", display = ":digraphs", desc = "Show digraph table" },
		},
	},

	-- Chapter 25: Editing formatted text
	{
		id = "25.2",
		title = "Text Alignment",
		help_tag = "25.2",
		exercises = {
			{ exercise = "ex:center", display = ":center", desc = "Center lines" },
			{ exercise = "ex:right", display = ":right", desc = "Right-justify lines" },
			{ exercise = "ex:left", display = ":left", desc = "Left-align lines" },
		},
	},
	{
		id = "25.3",
		title = "Indent/Unindent",
		help_tag = "25.3",
		exercises = {
			{ exercise = ">>", display = ">>", desc = "Indent line" },
			{ exercise = "<<", display = "<<", desc = "Unindent line" },
			{ exercise = "ex:retab", display = ":retab", desc = "Convert indentation" },
		},
	},
	{
		id = "25.4g",
		title = "Screen Line Movement",
		help_tag = "25.4",
		exercises = {
			{ exercise = "g0", display = "g0", desc = "Visible line start" },
			{ exercise = "g^", display = "g^", desc = "Visible first non-blank" },
			{ exercise = "gm", display = "gm", desc = "Middle of screen line" },
			{ exercise = "g$", display = "g$", desc = "Visible line end" },
			{ exercise = "gj", display = "gj", desc = "Screen line down" },
			{ exercise = "gk", display = "gk", desc = "Screen line up" },
		},
	},
	{
		id = "25.4h",
		title = "Horizontal Scroll",
		help_tag = "25.4",
		exercises = {
			{ exercise = "zh", display = "zh", desc = "Scroll right 1" },
			{ exercise = "zl", display = "zl", desc = "Scroll left 1" },
			{ exercise = "zH", display = "zH", desc = "Scroll right half" },
			{ exercise = "zL", display = "zL", desc = "Scroll left half" },
			{ exercise = "zs", display = "zs", desc = "Cursor to screen start" },
			{ exercise = "ze", display = "ze", desc = "Cursor to screen end" },
		},
	},
	{
		id = "25.5",
		title = "Virtual Replace",
		help_tag = "25.5",
		exercises = {
			{ exercise = "gr{char}", display = "gr{char}", desc = "Virtual replace char" },
			{ exercise = "gR", display = "gR", desc = "Virtual replace mode" },
		},
	},

	-- Chapter 26: Repeating
	{
		id = "26.1",
		title = "Reselect Visual",
		help_tag = "26.1",
		exercises = {
			{ exercise = "gv", display = "gv", desc = "Reselect visual" },
		},
	},
	{
		id = "26.2",
		title = "Increment / Decrement",
		help_tag = "26.2",
		exercises = {
			{ exercise = "<C-a>", display = "Ctrl-A", desc = "Increment number" },
			{ exercise = "<C-x>", display = "Ctrl-X", desc = "Decrement number" },
		},
	},
	{
		-- |26.2| teaches this with a count ("5 CTRL-A"), which is the form that makes
		-- the command worth knowing.
		id = "26.2c",
		title = "Counted Increment",
		help_tag = "26.2",
		exercises = {
			{ exercise = "[count]<C-a>", display = "[count]Ctrl-A", desc = "Add N to number" },
			{ exercise = "[count]<C-x>", display = "[count]Ctrl-X", desc = "Subtract N from number" },
		},
	},
	{
		id = "26.3",
		title = "Batch Commands",
		help_tag = "26.3",
		exercises = {
			{ exercise = "ex:argdo", display = ":argdo", desc = "Do on all args" },
			{ exercise = "ex:windo", display = ":windo", desc = "Do on all windows" },
			{ exercise = "ex:bufdo", display = ":bufdo", desc = "Do on all buffers" },
		},
	},

	-- Chapter 28: Folding
	{
		id = "28.2",
		title = "Folding",
		help_tag = "28.2",
		exercises = {
			-- zf is an operator, so `zf` alone is never a completed action: it waits
			-- for a motion. Coach counts action strings, not families, so the
			-- exercise names one concrete fold -- this line and the next.
			{ exercise = "zfj", display = "zfj", desc = "Create fold over 2 lines" },
			{ exercise = "zo", display = "zo", desc = "Open fold" },
			{ exercise = "zc", display = "zc", desc = "Close fold" },
			{ exercise = "zO", display = "zO", desc = "Open recursive" },
			{ exercise = "zC", display = "zC", desc = "Close recursive" },
			{ exercise = "zr", display = "zr", desc = "Reduce fold level" },
			{ exercise = "zm", display = "zm", desc = "More folding" },
			{ exercise = "zR", display = "zR", desc = "Open all" },
			{ exercise = "zM", display = "zM", desc = "Close all" },
			{ exercise = "zi", display = "zi", desc = "Toggle folding" },
			{ exercise = "zn", display = "zn", desc = "Disable folding" },
			{ exercise = "zN", display = "zN", desc = "Re-enable folding" },
			{ exercise = "zd", display = "zd", desc = "Delete fold" },
			{ exercise = "zD", display = "zD", desc = "Delete folds recursive" },
		},
	},

	-- Chapter 29: Moving through programs
	{
		id = "29.1",
		title = "Tag Navigation",
		help_tag = "29.1",
		exercises = {
			{ exercise = "<C-w>]", display = "Ctrl-W ]", desc = "Split and jump to tag" },
			{ exercise = "ex:tag", display = ":tag", desc = "Jump to tag" },
			{ exercise = "ex:tags", display = ":tags", desc = "Show tag stack" },
			{ exercise = "ex:stag", display = ":stag", desc = "Split and jump to tag" },
			{ exercise = "ex:tnext", display = ":tnext", desc = "Next tag match" },
			{ exercise = "ex:tprevious", display = ":tprevious", desc = "Prev tag match" },
			{ exercise = "ex:tselect", display = ":tselect", desc = "Select from tag matches" },
		},
	},
	{
		id = "29.2",
		title = "Preview Window",
		help_tag = "29.2",
		exercises = {
			{ exercise = "<C-w>}", display = "Ctrl-W }", desc = "Preview tag" },
			{ exercise = "ex:ptag", display = ":ptag", desc = "Open preview for tag" },
			{ exercise = "ex:pclose", display = ":pclose", desc = "Close preview window" },
			{ exercise = "ex:pedit", display = ":pedit", desc = "Edit in preview window" },
			{ exercise = "ex:psearch", display = ":psearch", desc = "Search in preview" },
		},
	},
	{
		id = "29.3",
		title = "Code Block Movement",
		help_tag = "29.3",
		exercises = {
			{ exercise = "[[", display = "[[", desc = "Prev outer {" },
			{ exercise = "]]", display = "]]", desc = "Next function" },
			{ exercise = "][", display = "][", desc = "End of outer block" },
			{ exercise = "[]", display = "[]", desc = "Backward to function end" },
			{ exercise = "[{", display = "[{", desc = "Start of block" },
			{ exercise = "]}", display = "]}", desc = "End of block" },
			{ exercise = "[(", display = "[(", desc = "Unclosed ( left" },
			{ exercise = "])", display = "])", desc = "Unclosed ) right" },
			{ exercise = "[#", display = "[#", desc = "Unclosed #if" },
			{ exercise = "]#", display = "]#", desc = "Next #else/#endif" },
			{ exercise = "[/", display = "[/", desc = "Start of C comment" },
			{ exercise = "]/", display = "]/", desc = "End of C comment" },
			{ exercise = "[m", display = "[m", desc = "Prev method start" },
			{ exercise = "]m", display = "]m", desc = "Next method start" },
		},
	},
	{
		id = "29.4",
		title = "Find Identifiers",
		help_tag = "29.4",
		exercises = {
			{ exercise = "[I", display = "[I", desc = "List all matches for word" },
			{ exercise = "[i", display = "[i", desc = "Show first match for word" },
			{ exercise = "[D", display = "[D", desc = "List #define matches" },
			{ exercise = "[d", display = "[d", desc = "Show first #define match" },
			{ exercise = "ex:checkpath", display = ":checkpath", desc = "Check include paths" },
		},
	},
	{
		id = "29.5",
		title = "Go to Declaration",
		help_tag = "29.5",
		exercises = {
			{ exercise = "gD", display = "gD", desc = "Global declaration" },
			{ exercise = "gd", display = "gd", desc = "Local declaration" },
		},
	},

	-- Chapter 30: Editing programs
	{
		id = "30.1",
		title = "Compile and Quickfix",
		help_tag = "30.1",
		exercises = {
			{ exercise = "ex:make", display = ":make", desc = "Run make" },
			{ exercise = "ex:cnext", display = ":cnext", desc = "Next error" },
			{ exercise = "ex:cprevious", display = ":cprevious", desc = "Prev error" },
			{ exercise = "ex:cc", display = ":cc", desc = "Show current error" },
			{ exercise = "ex:clist", display = ":clist", desc = "List errors" },
			{ exercise = "ex:cfirst", display = ":cfirst", desc = "First error" },
			{ exercise = "ex:clast", display = ":clast", desc = "Last error" },
			{ exercise = "ex:colder", display = ":colder", desc = "Previous error list" },
			{ exercise = "ex:cnewer", display = ":cnewer", desc = "Next error list" },
			{ exercise = "ex:compiler", display = ":compiler", desc = "Load compiler settings" },
		},
	},
	{
		id = "30.2",
		title = "Re-indent",
		help_tag = "30.2",
		exercises = {
			{ exercise = "==", display = "==", desc = "Re-indent line" },
			{ exercise = "=G", display = "=G", desc = "Re-indent to EOF" },
			{ exercise = "=a{", display = "=a{", desc = "Re-indent {} block" },
			{ exercise = ">i{", display = ">i{", desc = "Indent inside {} block" },
		},
	},

	-- Chapter 31: Exploiting the GUI
	{
		id = "31.1",
		title = "Browse and Confirm",
		help_tag = "31.1",
		exercises = {
			{ exercise = "ex:browse", display = ":browse edit", desc = "Browse for file" },
			{ exercise = "ex:confirm", display = ":confirm edit", desc = "Edit with confirmation" },
		},
	},

	-- Chapter 32: Undo tree
	{
		id = "32.3",
		title = "Undo Tree Navigation",
		help_tag = "32.3",
		exercises = {
			{ exercise = "g-", display = "g-", desc = "Older state" },
			{ exercise = "g+", display = "g+", desc = "Newer state" },
			{ exercise = "ex:undo", display = ":undo {N}", desc = "Jump to undo state" },
		},
	},
	{
		id = "32.4",
		title = "Time Travel Undo",
		help_tag = "32.4",
		exercises = {
			{ exercise = "ex:earlier", display = ":earlier", desc = "Go back in time" },
			{ exercise = "ex:later", display = ":later", desc = "Go forward in time" },
			{ exercise = "ex:undolist", display = ":undolist", desc = "Show undo tree" },
		},
	},
}
