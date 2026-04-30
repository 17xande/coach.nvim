-- Session: Making small changes (Neovim user-manual chapter 04).

return {
	{
		id = "04.1",
		title = "Operator + Motion",
		help_tag = "04.1",
		exercises = {
			{ exercise = "dw", display = "dw", desc = "Delete word" },
			{ exercise = "d$", display = "d$", desc = "Delete to EOL" },
		},
	},
	{
		id = "04.2",
		title = "Change Operator",
		help_tag = "04.2",
		exercises = {
			{ exercise = "cc", display = "cc", desc = "Change line" },
			{ exercise = "C", display = "C", desc = "Change to EOL" },
			{ exercise = "r", display = "r", desc = "Replace char" },
			{ exercise = "s", display = "s", desc = "Substitute char" },
		},
	},
	{
		id = "04.2s",
		title = "Delete Shortcuts",
		help_tag = "04.2",
		exercises = {
			{ exercise = "D", display = "D", desc = "Delete to EOL" },
			{ exercise = "X", display = "X", desc = "Delete char left" },
			{ exercise = "S", display = "S", desc = "Substitute line" },
		},
	},
	{
		id = "04.3",
		title = "Repeating a Change",
		help_tag = "04.3",
		exercises = {
			{ exercise = ".", display = ".", desc = "Repeat change" },
		},
	},
	{
		id = "04.4",
		title = "Visual Mode",
		help_tag = "04.4",
		exercises = {
			{ exercise = "v", display = "v", desc = "Visual char" },
			{ exercise = "V", display = "V", desc = "Visual line" },
			{ exercise = "<C-v>", display = "Ctrl-V", desc = "Visual block" },
		},
	},
	{
		id = "04.5",
		title = "Moving Text",
		help_tag = "04.5",
		exercises = {
			{ exercise = "p", display = "p", desc = "Put after" },
			{ exercise = "P", display = "P", desc = "Put before" },
		},
	},
	{
		id = "04.6",
		title = "Copying Text",
		help_tag = "04.6",
		exercises = {
			{ exercise = "yy", display = "yy", desc = "Yank line" },
			{ exercise = "Y", display = "Y", desc = "Yank to EOL" },
		},
	},
	{
		id = "04.8",
		title = "Text Objects",
		help_tag = "04.8",
		exercises = {
			{ exercise = "daw", display = "daw", desc = "Delete a word" },
			{ exercise = "diw", display = "diw", desc = "Delete inner word" },
			{ exercise = "cis", display = "cis", desc = "Change inner sent" },
			{ exercise = "das", display = "das", desc = "Delete a sentence" },
		},
	},
	{
		id = "04.9",
		title = "Replace Mode",
		help_tag = "04.9",
		exercises = {
			{ exercise = "R", display = "R", desc = "Replace mode" },
		},
	},
	{
		id = "04.10",
		title = "More Insert/Case",
		help_tag = "04.10",
		exercises = {
			{ exercise = "~", display = "~", desc = "Toggle case" },
			{ exercise = "I", display = "I", desc = "Insert at line start" },
			{ exercise = "A", display = "A", desc = "Append at line end" },
		},
	},
}
