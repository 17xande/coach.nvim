-- Minimal init for headless testing (no user config, no plugins)
-- Prevent plugin/coach.lua from auto-running so tests control setup themselves
vim.g.loaded_coach = true
vim.opt.runtimepath:append(vim.fn.getcwd())
-- track-action.nvim is a runtime dependency, so the specs that exercise the seam
-- with it need it reachable. A sibling checkout is where it lives in development;
-- specs that use it skip themselves when there is none.
local track_action = vim.fn.fnamemodify(vim.fn.getcwd(), ":h") .. "/track-action.nvim"
if vim.fn.isdirectory(track_action) == 1 then
	vim.opt.runtimepath:append(track_action)
end
package.path = vim.fn.getcwd() .. "/tests/?.lua;" .. package.path
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.cmd("filetype off")
vim.cmd("syntax off")
