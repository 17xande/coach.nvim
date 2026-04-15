-- Minimal init for headless testing (no user config, no plugins)
-- Prevent plugin/coach.lua from auto-running so tests control setup themselves
vim.g.loaded_coach = true
vim.opt.runtimepath:append(vim.fn.getcwd())
package.path = vim.fn.getcwd() .. "/tests/?.lua;" .. package.path
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.cmd("filetype off")
vim.cmd("syntax off")
