-- Volume: Windows & Splits
-- Practice splitting, navigating, and resizing Neovim windows.

return {
	{
		id = "win.1",
		title = "Opening Splits",
		help_tag = "opening-window",
		actions = {
			{ action = "<C-w>s", display = "Ctrl-W s", desc = "Split horizontally" },
			{ action = "<C-w>v", display = "Ctrl-W v", desc = "Split vertically" },
			{ action = "<C-w>n", display = "Ctrl-W n", desc = "New empty split" },
		},
	},
	{
		id = "win.2",
		title = "Moving Between Windows",
		help_tag = "window-move-cursor",
		actions = {
			{ action = "<C-w>h", display = "Ctrl-W h", desc = "Go to left window" },
			{ action = "<C-w>j", display = "Ctrl-W j", desc = "Go to window below" },
			{ action = "<C-w>k", display = "Ctrl-W k", desc = "Go to window above" },
			{ action = "<C-w>l", display = "Ctrl-W l", desc = "Go to right window" },
			{ action = "<C-w>w", display = "Ctrl-W w", desc = "Cycle to next window" },
		},
	},
	{
		id = "win.3",
		title = "Resizing & Closing",
		help_tag = "window-resize",
		actions = {
			{ action = "<C-w>=", display = "Ctrl-W =", desc = "Equalize window sizes" },
			{ action = "<C-w>_", display = "Ctrl-W _", desc = "Maximize height" },
			{ action = "<C-w>|", display = "Ctrl-W |", desc = "Maximize width" },
			{ action = "<C-w>q", display = "Ctrl-W q", desc = "Close current window" },
			{ action = "<C-w>o", display = "Ctrl-W o", desc = "Close all other windows" },
		},
	},
}
