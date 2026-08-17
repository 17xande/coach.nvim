-- Session: The first steps in Vim (Neovim user-manual chapter 02).

return {
	{
		id = "02.2",
		title = "Inserting Text",
		help_tag = "02.2",
		exercises = {
			{ exercise = "i", display = "i", desc = "Insert mode" },
		},
	},
	{
		id = "02.3",
		title = "Moving Around",
		help_tag = "02.3",
		exercises = {
			{ exercise = "h", display = "h", desc = "Move left" },
			{ exercise = "j", display = "j", desc = "Move down" },
			{ exercise = "k", display = "k", desc = "Move up" },
			{ exercise = "l", display = "l", desc = "Move right" },
		},
	},
	{
		id = "02.4",
		title = "Deleting Characters",
		help_tag = "02.4",
		exercises = {
			{ exercise = "x", display = "x", desc = "Delete char" },
			{ exercise = "dd", display = "dd", desc = "Delete line" },
			{ exercise = "J", display = "J", desc = "Join lines" },
		},
	},
	{
		id = "02.5",
		title = "Undo and Redo",
		help_tag = "02.5",
		exercises = {
			{ exercise = "u", display = "u", desc = "Undo" },
			{ exercise = "<C-r>", display = "Ctrl-R", desc = "Redo" },
			{ exercise = "U", display = "U", desc = "Undo line" },
		},
	},
	{
		id = "02.6",
		title = "Other Editing Commands",
		help_tag = "02.6",
		exercises = {
			{ exercise = "a", display = "a", desc = "Append" },
			{ exercise = "o", display = "o", desc = "Open below" },
			{ exercise = "O", display = "O", desc = "Open above" },
		},
	},
	{
		-- The manual introduces counts here (|02.6|, "Using a count") and keeps
		-- raising them: 03.5, 04.1, 10.1, 23.3, 26.2. A counted command is its own
		-- exercise -- `w` and `[count]w` are different disciplines, and any count
		-- credits the rep, the digit does not matter.
		id = "02.6c",
		title = "Using a Count",
		help_tag = "02.6",
		exercises = {
			{ exercise = "[count]x", display = "[count]x", desc = "Delete N chars" },
			{ exercise = "[count]dd", display = "[count]dd", desc = "Delete N lines" },
			{ exercise = "[count]j", display = "[count]j", desc = "N lines down" },
			{ exercise = "[count]k", display = "[count]k", desc = "N lines up" },
			{ exercise = "[count]o", display = "[count]o", desc = "Open N lines below" },
		},
	},
	{
		id = "02.7",
		title = "Save and Quit",
		help_tag = "02.7",
		exercises = {
			{ exercise = "ZZ", display = "ZZ", desc = "Save and quit" },
			{ exercise = "ex:quit", display = ":q", desc = "Quit" },
			{ exercise = "ex:quit!", display = ":q!", desc = "Quit without saving" },
			{ exercise = "ex:edit!", display = ":e!", desc = "Reload file" },
		},
	},
	{
		id = "02.8",
		title = "Finding Help",
		help_tag = "02.8",
		exercises = {
			{ exercise = "<C-]>", display = "Ctrl-]", desc = "Jump to tag" },
			{ exercise = "<C-t>", display = "Ctrl-T", desc = "Pop tag" },
			{ exercise = "<C-o>", display = "Ctrl-O", desc = "Jump back" },
			{ exercise = "ex:help", display = ":help", desc = "Open help" },
			{ exercise = "ex:helpgrep", display = ":helpgrep", desc = "Search all help" },
			{ exercise = "ex:cnext", display = ":cnext", desc = "Next quickfix result" },
			{ exercise = "ex:copen", display = ":copen", desc = "Open quickfix window" },
			{ exercise = "ex:Tutor", display = ":Tutor", desc = "Open Vim tutorial" },
		},
	},
}
