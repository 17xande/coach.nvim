-- Minimal init for headless testing (no user config, no plugins)
vim.opt.runtimepath:append(vim.fn.getcwd())
package.path = vim.fn.getcwd() .. "/tests/?.lua;" .. package.path
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.cmd("filetype off")
vim.cmd("syntax off")
