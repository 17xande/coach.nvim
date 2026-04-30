-- Session: Folds
-- Practice creating, navigating, and toggling manual folds.

return {
	{
		id = "fold.1",
		title = "Creating and Deleting Folds",
		help_tag = "fold-manual",
		exercises = {
			{ exercise = "zf", display = "zf", desc = "Create fold (with motion)" },
			{ exercise = "zd", display = "zd", desc = "Delete fold under cursor" },
			{ exercise = "zE", display = "zE", desc = "Delete all folds in buffer" },
		},
	},
	{
		id = "fold.2",
		title = "Opening and Closing Folds",
		help_tag = "fold-commands",
		exercises = {
			{ exercise = "zo", display = "zo", desc = "Open fold" },
			{ exercise = "zc", display = "zc", desc = "Close fold" },
			{ exercise = "za", display = "za", desc = "Toggle fold" },
			{ exercise = "zR", display = "zR", desc = "Open all folds" },
			{ exercise = "zM", display = "zM", desc = "Close all folds" },
		},
	},
	{
		id = "fold.3",
		title = "Navigating Folds",
		help_tag = "fold-motions",
		exercises = {
			{ exercise = "zj", display = "zj", desc = "Next fold start" },
			{ exercise = "zk", display = "zk", desc = "Previous fold end" },
			{ exercise = "[z", display = "[z", desc = "Start of current fold" },
			{ exercise = "]z", display = "]z", desc = "End of current fold" },
		},
	},
}
