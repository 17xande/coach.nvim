-- Session: Settings, syntax, files, windows
-- (Neovim user-manual chapters 05, 06, 07, 08).

return {
	-- Chapter 05: Set your settings
	{
		id = "05.1",
		title = "Edit vimrc",
		help_tag = "05.1",
		exercises = {
			{ exercise = "ex:edit", display = ":edit", desc = "Edit file" },
		},
	},
	{
		id = "05.3",
		title = "Mappings",
		help_tag = "05.3",
		exercises = {
			{ exercise = "ex:map", display = ":map", desc = "Create/list mappings" },
		},
	},
	{
		id = "05.4",
		title = "Packages",
		help_tag = "05.4",
		exercises = {
			{ exercise = "ex:packadd", display = ":packadd", desc = "Load package" },
		},
	},
	{
		id = "05.6",
		title = "Help Files",
		help_tag = "05.6",
		exercises = {
			{ exercise = "ex:helptags", display = ":helptags", desc = "Generate help tags" },
		},
	},
	{
		id = "05.7",
		title = "Option Window",
		help_tag = "05.7",
		exercises = {
			{ exercise = "ex:options", display = ":options", desc = "Option window" },
		},
	},

	-- Chapter 06: Syntax highlighting
	{
		id = "06.2",
		title = "Redraw Screen",
		help_tag = "06.2",
		exercises = {
			{ exercise = "<C-l>", display = "Ctrl-L", desc = "Redraw screen" },
		},
	},
	{
		id = "06.3",
		title = "Colorscheme",
		help_tag = "06.3",
		exercises = {
			{ exercise = "ex:colorscheme", display = ":colorscheme", desc = "Apply colorscheme" },
		},
	},
	{
		id = "06.4",
		title = "Toggle Syntax",
		help_tag = "06.4",
		exercises = {
			{ exercise = "ex:syntax", display = ":syntax", desc = "Toggle syntax" },
		},
	},

	-- Chapter 07: Editing more than one file
	{
		id = "07.1",
		title = "File Operations",
		help_tag = "07.1",
		exercises = {
			{ exercise = "ex:edit", display = ":edit", desc = "Open file" },
			{ exercise = "ex:write", display = ":write", desc = "Save file" },
			{ exercise = "ex:hide", display = ":hide", desc = "Hide buffer, switch file" },
		},
	},
	{
		id = "07.2",
		title = "Argument List",
		help_tag = "07.2",
		exercises = {
			{ exercise = "ex:next", display = ":next", desc = "Next file" },
			{ exercise = "ex:previous", display = ":previous", desc = "Previous file" },
			{ exercise = "ex:first", display = ":first", desc = "First file" },
			{ exercise = "ex:last", display = ":last", desc = "Last file" },
			{ exercise = "ex:args", display = ":args", desc = "Show arg list" },
			{ exercise = "ex:wnext", display = ":wnext", desc = "Write, then next file" },
			{ exercise = "ex:wprevious", display = ":wprevious", desc = "Write, then prev file" },
		},
	},
	{
		id = "07.3",
		title = "Alternate File",
		help_tag = "07.3",
		exercises = {
			{ exercise = "<C-^>", display = "Ctrl-^", desc = "Alternate file" },
			{ exercise = "`\"", display = "`\"", desc = "Pos when last left file" },
			{ exercise = "`.", display = "`.", desc = "Pos of last change" },
		},
	},
	{
		id = "07.7",
		title = "Rename/Save As",
		help_tag = "07.7",
		exercises = {
			{ exercise = "ex:saveas", display = ":saveas", desc = "Save as new file" },
			{ exercise = "ex:file", display = ":file", desc = "Rename buffer" },
		},
	},

	-- Chapter 08: Splitting windows
	{
		id = "08.1",
		title = "Split Windows",
		help_tag = "08.1",
		exercises = {
			{ exercise = "ex:split", display = ":split", desc = "Horizontal split" },
			{ exercise = "ex:close", display = ":close", desc = "Close window" },
			{ exercise = "ex:only", display = ":only", desc = "Keep only current" },
			{ exercise = "ex:new", display = ":new", desc = "New empty split" },
		},
	},
	{
		id = "08.3",
		title = "Window Size",
		help_tag = "08.3",
		exercises = {
			{ exercise = "<C-w>+", display = "Ctrl-W +", desc = "Increase height" },
			{ exercise = "<C-w>-", display = "Ctrl-W -", desc = "Decrease height" },
			{ exercise = "<C-w>_", display = "Ctrl-W _", desc = "Max height" },
			{ exercise = "<C-w>=", display = "Ctrl-W =", desc = "Equal sizes" },
		},
	},
	{
		id = "08.4",
		title = "Window Navigation",
		help_tag = "08.4",
		exercises = {
			{ exercise = "<C-w>w", display = "Ctrl-W w", desc = "Next window" },
			{ exercise = "<C-w>h", display = "Ctrl-W h", desc = "Window left" },
			{ exercise = "<C-w>j", display = "Ctrl-W j", desc = "Window down" },
			{ exercise = "<C-w>k", display = "Ctrl-W k", desc = "Window up" },
			{ exercise = "<C-w>l", display = "Ctrl-W l", desc = "Window right" },
			{ exercise = "<C-w>t", display = "Ctrl-W t", desc = "Top window" },
			{ exercise = "<C-w>b", display = "Ctrl-W b", desc = "Bottom window" },
		},
	},
	{
		id = "08.4v",
		title = "Vertical Splits",
		help_tag = "08.4",
		exercises = {
			{ exercise = "ex:vsplit", display = ":vsplit", desc = "Vertical split" },
			{ exercise = "ex:vnew", display = ":vnew", desc = "Vertical new buffer" },
			{ exercise = "ex:vertical", display = ":vertical", desc = "Force vertical modifier" },
		},
	},
	{
		id = "08.5",
		title = "Moving Windows",
		help_tag = "08.5",
		exercises = {
			{ exercise = "<C-w>K", display = "Ctrl-W K", desc = "Move to top" },
			{ exercise = "<C-w>J", display = "Ctrl-W J", desc = "Move to bottom" },
			{ exercise = "<C-w>H", display = "Ctrl-W H", desc = "Move to far left" },
			{ exercise = "<C-w>L", display = "Ctrl-W L", desc = "Move to far right" },
		},
	},
	{
		id = "08.6",
		title = "All Windows",
		help_tag = "08.6",
		exercises = {
			{ exercise = "ex:qall", display = ":qall", desc = "Quit all" },
			{ exercise = "ex:wall", display = ":wall", desc = "Write all" },
			{ exercise = "ex:wqall", display = ":wqall", desc = "Write and quit all" },
			{ exercise = "ex:all", display = ":all", desc = "Open window for each arg" },
		},
	},
	{
		id = "08.7",
		title = "Diff Navigation",
		help_tag = "08.7",
		exercises = {
			{ exercise = "]c", display = "]c", desc = "Next change" },
			{ exercise = "[c", display = "[c", desc = "Prev change" },
			{ exercise = "dp", display = "dp", desc = "Diff put" },
			{ exercise = "do", display = "do", desc = "Diff obtain" },
			{ exercise = "ex:diffsplit", display = ":diffsplit", desc = "Diff split with file" },
			{ exercise = "ex:diffpatch", display = ":diffpatch", desc = "Diff apply patch" },
			{ exercise = "ex:diffupdate", display = ":diffupdate", desc = "Refresh diff" },
		},
	},
	{
		id = "08.9",
		title = "Tab Pages",
		help_tag = "08.9",
		exercises = {
			{ exercise = "gt", display = "gt", desc = "Next tab" },
			{ exercise = "gT", display = "gT", desc = "Prev tab" },
			{ exercise = "ex:tabedit", display = ":tabedit", desc = "Open in new tab" },
			{ exercise = "ex:tab", display = ":tab split", desc = "Dup current in new tab" },
			{ exercise = "ex:tabonly", display = ":tabonly", desc = "Close other tabs" },
		},
	},
}
