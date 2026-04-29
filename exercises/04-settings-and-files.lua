-- Volume: Settings, syntax, files, windows
-- (Neovim user-manual chapters 05, 06, 07, 08).

return {
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
}
