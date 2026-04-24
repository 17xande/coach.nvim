-- Volume: Folds
-- Practice creating, navigating, and toggling manual folds.

return {
	{
		id = "fold.1",
		title = "Creating and Deleting Folds",
		help_tag = "fold-manual",
		actions = {
			{ action = "zf", display = "zf", desc = "Create fold (with motion)" },
			{ action = "zd", display = "zd", desc = "Delete fold under cursor" },
			{ action = "zE", display = "zE", desc = "Delete all folds in buffer" },
		},
	},
	{
		id = "fold.2",
		title = "Opening and Closing Folds",
		help_tag = "fold-commands",
		actions = {
			{ action = "zo", display = "zo", desc = "Open fold" },
			{ action = "zc", display = "zc", desc = "Close fold" },
			{ action = "za", display = "za", desc = "Toggle fold" },
			{ action = "zR", display = "zR", desc = "Open all folds" },
			{ action = "zM", display = "zM", desc = "Close all folds" },
		},
	},
	{
		id = "fold.3",
		title = "Navigating Folds",
		help_tag = "fold-motions",
		actions = {
			{ action = "zj", display = "zj", desc = "Next fold start" },
			{ action = "zk", display = "zk", desc = "Previous fold end" },
			{ action = "[z", display = "[z", desc = "Start of current fold" },
			{ action = "]z", display = "]z", desc = "End of current fold" },
		},
	},
}
