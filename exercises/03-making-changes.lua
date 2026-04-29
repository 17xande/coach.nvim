-- Volume: Making small changes (Neovim user-manual chapter 04).

return {
	{
		id = "04.1",
		title = "Operator + Motion",
		help_tag = "04.1",
		actions = {
			{ action = "dw", display = "dw", desc = "Delete word" },
			{ action = "d$", display = "d$", desc = "Delete to EOL" },
		},
	},
	{
		id = "04.2",
		title = "Change Operator",
		help_tag = "04.2",
		actions = {
			{ action = "cc", display = "cc", desc = "Change line" },
			{ action = "C", display = "C", desc = "Change to EOL" },
			{ action = "r", display = "r", desc = "Replace char" },
			{ action = "s", display = "s", desc = "Substitute char" },
		},
	},
	{
		id = "04.2s",
		title = "Delete Shortcuts",
		help_tag = "04.2",
		actions = {
			{ action = "D", display = "D", desc = "Delete to EOL" },
			{ action = "X", display = "X", desc = "Delete char left" },
			{ action = "S", display = "S", desc = "Substitute line" },
		},
	},
	{
		id = "04.3",
		title = "Repeating a Change",
		help_tag = "04.3",
		actions = {
			{ action = ".", display = ".", desc = "Repeat change" },
		},
	},
	{
		id = "04.4",
		title = "Visual Mode",
		help_tag = "04.4",
		actions = {
			{ action = "v", display = "v", desc = "Visual char" },
			{ action = "V", display = "V", desc = "Visual line" },
			{ action = "<C-v>", display = "Ctrl-V", desc = "Visual block" },
		},
	},
	{
		id = "04.5",
		title = "Moving Text",
		help_tag = "04.5",
		actions = {
			{ action = "p", display = "p", desc = "Put after" },
			{ action = "P", display = "P", desc = "Put before" },
		},
	},
	{
		id = "04.6",
		title = "Copying Text",
		help_tag = "04.6",
		actions = {
			{ action = "yy", display = "yy", desc = "Yank line" },
			{ action = "Y", display = "Y", desc = "Yank to EOL" },
		},
	},
	{
		id = "04.8",
		title = "Text Objects",
		help_tag = "04.8",
		actions = {
			{ action = "daw", display = "daw", desc = "Delete a word" },
			{ action = "diw", display = "diw", desc = "Delete inner word" },
			{ action = "cis", display = "cis", desc = "Change inner sent" },
			{ action = "das", display = "das", desc = "Delete a sentence" },
		},
	},
	{
		id = "04.9",
		title = "Replace Mode",
		help_tag = "04.9",
		actions = {
			{ action = "R", display = "R", desc = "Replace mode" },
		},
	},
	{
		id = "04.10",
		title = "More Insert/Case",
		help_tag = "04.10",
		actions = {
			{ action = "~", display = "~", desc = "Toggle case" },
			{ action = "I", display = "I", desc = "Insert at line start" },
			{ action = "A", display = "A", desc = "Append at line end" },
		},
	},
}
