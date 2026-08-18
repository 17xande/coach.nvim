-- Fail the build unless this Neovim can report actions at all.
--
-- coach counts reps that track-action reports, and track-action reports nothing
-- without the CmdAtom autocmd, which arrived in Neovim 0.13. Without it coach is
-- silent, and a silent coach makes a *green* suite: an emit check sees no actions
-- and finds nothing to disagree with. So the version check is a build step, not
-- an assertion inside a spec that a missing event would skip.
--
-- Run via `make preflight`, and as a dependency of `make test`.

local v = vim.version()
local have = string.format("%d.%d.%d", v.major, v.minor, v.patch)

if vim.fn.exists("##CmdAtom") ~= 1 then
  io.stderr:write(
    ("CmdAtom is missing: this is Neovim %s, and the event needs 0.13.\n"):format(have)
      .. "Run `mise install` in this directory -- mise.toml pins neovim@nightly here,\n"
      .. "and the system nvim on this machine is 0.12.x and cannot run the suite.\n"
  )
  vim.cmd("cquit 1")
end
