-- Session: Bigger changes, recovery, tricks
-- (Neovim user-manual chapters 10, 11, 12).

return {
	-- Chapter 10: Making big changes
	{
		id = "10.1",
		title = "Macros",
		help_tag = "10.1",
		exercises = {
			{ exercise = "q", display = "q{a-z}", desc = "Record macro" },
			{ exercise = "@", display = "@{a-z}", desc = "Replay macro" },
			{ exercise = "@@", display = "@@", desc = "Replay last macro" },
		},
	},
	{
		id = "10.2",
		title = "Substitution",
		help_tag = "10.2",
		exercises = {
			{ exercise = "ex:substitute", display = ":s", desc = "Substitute" },
		},
	},
	{
		id = "10.4",
		title = "Global Command",
		help_tag = "10.4",
		exercises = {
			{ exercise = "ex:global", display = ":g", desc = "Global command" },
		},
	},
	{
		id = "10.6",
		title = "Read/Write Files",
		help_tag = "10.6",
		exercises = {
			{ exercise = "ex:read", display = ":read", desc = "Insert file below cursor" },
		},
	},
	{
		id = "10.7",
		title = "Format Text",
		help_tag = "10.7",
		exercises = {
			{ exercise = "gqap", display = "gqap", desc = "Format paragraph" },
			{ exercise = "gqq", display = "gqq", desc = "Format line" },
			{ exercise = "gq]/", display = "gq]/", desc = "Format C comment" },
		},
	},
	{
		id = "10.8",
		title = "Change Case",
		help_tag = "10.8",
		exercises = {
			{ exercise = "gUU", display = "gUU", desc = "Uppercase line" },
			{ exercise = "guu", display = "guu", desc = "Lowercase line" },
			{ exercise = "g~~", display = "g~~", desc = "Swap case line" },
			{ exercise = "gUw", display = "gUw", desc = "Uppercase word" },
			{ exercise = "guw", display = "guw", desc = "Lowercase word" },
		},
	},
	{
		id = "10.9",
		title = "External Programs",
		help_tag = "10.9",
		exercises = {
			{ exercise = "!!", display = "!!", desc = "Filter line through program" },
			{ exercise = "ex:!", display = ":!{cmd}", desc = "Execute shell command" },
		},
	},

	-- Chapter 11: Recovering from a crash
	{
		id = "11.1",
		title = "Recovery",
		help_tag = "11.1",
		exercises = {
			{ exercise = "ex:recover", display = ":recover", desc = "Recover from swap file" },
		},
	},

	-- Chapter 12: Clever tricks
	{
		id = "12.6",
		title = "Man Page Lookup",
		help_tag = "12.6",
		exercises = {
			{ exercise = "K", display = "K", desc = "Lookup man page" },
			{ exercise = "g<C-g>", display = "g Ctrl-G", desc = "Count words/lines/bytes" },
			{ exercise = "ex:Man", display = ":Man", desc = "Open man page in split" },
		},
	},
	{
		id = "12.8",
		title = "Grep and Quickfix",
		help_tag = "12.8",
		exercises = {
			{ exercise = "ex:grep", display = ":grep", desc = "Search files" },
			{ exercise = "ex:cnext", display = ":cnext", desc = "Next quickfix" },
			{ exercise = "ex:cprev", display = ":cprev", desc = "Prev quickfix" },
			{ exercise = "ex:clist", display = ":clist", desc = "List quickfix" },
		},
	},
}
