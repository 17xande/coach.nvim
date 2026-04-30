-- Session: Windows & Splits
-- Practice splitting, navigating, and resizing Neovim windows.

return {
	{
		id = "win.1",
		title = "Opening Splits",
		help_tag = "opening-window",
		exercises = {
			{ exercise = "<C-w>s", display = "Ctrl-W s", desc = "Split horizontally" },
			{ exercise = "<C-w>v", display = "Ctrl-W v", desc = "Split vertically" },
			{ exercise = "<C-w>n", display = "Ctrl-W n", desc = "New empty split" },
		},
	},
	{
		id = "win.2",
		title = "Moving Between Windows",
		help_tag = "window-move-cursor",
		exercises = {
			{ exercise = "<C-w>h", display = "Ctrl-W h", desc = "Go to left window" },
			{ exercise = "<C-w>j", display = "Ctrl-W j", desc = "Go to window below" },
			{ exercise = "<C-w>k", display = "Ctrl-W k", desc = "Go to window above" },
			{ exercise = "<C-w>l", display = "Ctrl-W l", desc = "Go to right window" },
			{ exercise = "<C-w>w", display = "Ctrl-W w", desc = "Cycle to next window" },
		},
	},
	{
		id = "win.3",
		title = "Resizing & Closing",
		help_tag = "window-resize",
		exercises = {
			{ exercise = "<C-w>=", display = "Ctrl-W =", desc = "Equalize window sizes" },
			{ exercise = "<C-w>_", display = "Ctrl-W _", desc = "Maximize height" },
			{ exercise = "<C-w>|", display = "Ctrl-W |", desc = "Maximize width" },
			{ exercise = "<C-w>q", display = "Ctrl-W q", desc = "Close current window" },
			{ exercise = "<C-w>o", display = "Ctrl-W o", desc = "Close all other windows" },
		},
	},
}
