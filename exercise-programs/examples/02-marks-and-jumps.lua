-- Session: Marks & Jumps
-- Practice placing marks and navigating the jump and change lists.

return {
	{
		id = "mark.1",
		title = "Setting and Going to Marks",
		help_tag = "mark-motions",
		exercises = {
			{ exercise = "ma", display = "ma", desc = "Set mark 'a' at cursor" },
			{ exercise = "mA", display = "mA", desc = "Set global mark 'A'" },
			{ exercise = "'a", display = "'a", desc = "Jump to line of mark 'a'" },
			{ exercise = "`a", display = "`a", desc = "Jump to position of mark 'a'" },
		},
	},
	{
		id = "mark.2",
		title = "The Jump List",
		help_tag = "jump-motions",
		exercises = {
			{ exercise = "<C-o>", display = "Ctrl-O", desc = "Jump backward" },
			-- <Tab>, not <C-i>: the same byte, and Neovim reports it as <Tab>.
			{ exercise = "<Tab>", display = "Ctrl-I", desc = "Jump forward" },
			{ exercise = "ex:jumps", display = ":jumps", desc = "Show the jump list" },
		},
	},
	{
		id = "mark.3",
		title = "The Change List",
		help_tag = "changelist",
		exercises = {
			{ exercise = "g;", display = "g;", desc = "Previous change" },
			{ exercise = "g,", display = "g,", desc = "Next change" },
			{ exercise = "ex:changes", display = ":changes", desc = "Show the change list" },
		},
	},
}
