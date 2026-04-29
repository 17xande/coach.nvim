-- Volume: Bigger changes, recovery, tricks
-- (Neovim user-manual chapters 10, 11, 12).

return {
	-- Chapter 10: Making big changes
	{
		id = "10.1",
		title = "Macros",
		help_tag = "10.1",
		actions = {
			{ action = "q", display = "q{a-z}", desc = "Record macro" },
			{ action = "@", display = "@{a-z}", desc = "Replay macro" },
			{ action = "@@", display = "@@", desc = "Replay last macro" },
		},
	},
	{
		id = "10.2",
		title = "Substitution",
		help_tag = "10.2",
		actions = {
			{ action = "ex:substitute", display = ":s", desc = "Substitute" },
		},
	},
	{
		id = "10.4",
		title = "Global Command",
		help_tag = "10.4",
		actions = {
			{ action = "ex:global", display = ":g", desc = "Global command" },
		},
	},
	{
		id = "10.6",
		title = "Read/Write Files",
		help_tag = "10.6",
		actions = {
			{ action = "ex:read", display = ":read", desc = "Insert file below cursor" },
		},
	},
	{
		id = "10.7",
		title = "Format Text",
		help_tag = "10.7",
		actions = {
			{ action = "gqap", display = "gqap", desc = "Format paragraph" },
			{ action = "gqq", display = "gqq", desc = "Format line" },
			{ action = "gq]/", display = "gq]/", desc = "Format C comment" },
		},
	},
	{
		id = "10.8",
		title = "Change Case",
		help_tag = "10.8",
		actions = {
			{ action = "gUU", display = "gUU", desc = "Uppercase line" },
			{ action = "guu", display = "guu", desc = "Lowercase line" },
			{ action = "g~~", display = "g~~", desc = "Swap case line" },
			{ action = "gUw", display = "gUw", desc = "Uppercase word" },
			{ action = "guw", display = "guw", desc = "Lowercase word" },
		},
	},
	{
		id = "10.9",
		title = "External Programs",
		help_tag = "10.9",
		actions = {
			{ action = "!!", display = "!!", desc = "Filter line through program" },
			{ action = "ex:!", display = ":!{cmd}", desc = "Execute shell command" },
		},
	},

	-- Chapter 11: Recovering from a crash
	{
		id = "11.1",
		title = "Recovery",
		help_tag = "11.1",
		actions = {
			{ action = "ex:recover", display = ":recover", desc = "Recover from swap file" },
		},
	},

	-- Chapter 12: Clever tricks
	{
		id = "12.6",
		title = "Man Page Lookup",
		help_tag = "12.6",
		actions = {
			{ action = "K", display = "K", desc = "Lookup man page" },
			{ action = "g<C-g>", display = "g Ctrl-G", desc = "Count words/lines/bytes" },
			{ action = "ex:Man", display = ":Man", desc = "Open man page in split" },
		},
	},
	{
		id = "12.8",
		title = "Grep and Quickfix",
		help_tag = "12.8",
		actions = {
			{ action = "ex:grep", display = ":grep", desc = "Search files" },
			{ action = "ex:cnext", display = ":cnext", desc = "Next quickfix" },
			{ action = "ex:cprev", display = ":cprev", desc = "Prev quickfix" },
			{ action = "ex:clist", display = ":clist", desc = "List quickfix" },
		},
	},
}
