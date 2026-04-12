if vim.g.loaded_coach then
	return
end
vim.g.loaded_coach = true

require("coach").setup()
