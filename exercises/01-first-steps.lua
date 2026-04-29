-- Volume: The first steps in Vim (Neovim user-manual chapter 02).

return {
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
}
