-- Volume: Marks & Jumps
-- Practice placing marks and navigating the jump and change lists.

return {
	{
		id = "mark.1",
		title = "Setting and Going to Marks",
		help_tag = "mark-motions",
		actions = {
			{ action = "ma", display = "ma", desc = "Set mark 'a' at cursor" },
			{ action = "mA", display = "mA", desc = "Set global mark 'A'" },
			{ action = "'a", display = "'a", desc = "Jump to line of mark 'a'" },
			{ action = "`a", display = "`a", desc = "Jump to position of mark 'a'" },
		},
	},
	{
		id = "mark.2",
		title = "The Jump List",
		help_tag = "jump-motions",
		actions = {
			{ action = "<C-o>", display = "Ctrl-O", desc = "Jump backward" },
			{ action = "<C-i>", display = "Ctrl-I", desc = "Jump forward" },
			{ action = "ex:jumps", display = ":jumps", desc = "Show the jump list" },
		},
	},
	{
		id = "mark.3",
		title = "The Change List",
		help_tag = "changelist",
		actions = {
			{ action = "g;", display = "g;", desc = "Previous change" },
			{ action = "g,", display = "g,", desc = "Next change" },
			{ action = "ex:changes", display = ":changes", desc = "Show the change list" },
		},
	},
}
