# Example coach.nvim exercise volumes

This directory contains a small set of example **volumes** you can use to test
coach.nvim's custom-source loading. Each `.lua` file in `exercises/` is one
volume made up of multiple chapters.

## Volumes

| File | Topic |
| --- | --- |
| `exercises/01-windows.lua` | Window splits, navigation, resizing |
| `exercises/02-marks-and-jumps.lua` | Marks, jump list, change list |
| `exercises/03-folds.lua` | Manual folds: create, toggle, navigate |

## Testing a local directory source

Point a set at this directory directly:

```lua
require("coach").setup({
  sets = {
    { name = "neovim-manual" },
    { name = "extras", source = "~/dev/coach.nvim/examples/exercises" },
  },
})
```

Then `:CoachVolume extras/01-windows` to switch.

## Testing a GitHub source

1. Create a new GitHub repo (e.g. `you/coach-extras`).
2. Copy the `exercises/` directory from here to the root of that repo.
3. Push.
4. Configure coach.nvim:

   ```lua
   require("coach").setup({
     sets = {
       { name = "neovim-manual" },
       { name = "extras", source = "github:you/coach-extras" },
     },
   })
   ```

5. Start Neovim. coach.nvim will clone the repo in the background to
   `~/.local/share/nvim/coach/sets/extras/`.
6. `:CoachVolume` to pick a volume. Progress is saved per volume at
   `~/.local/share/nvim/coach/progress/extras/<volume>.json`.
7. Push a change to the repo, then `:CoachUpdate extras` to pull it.

## Volume file format

Each volume returns a list of chapter tables:

```lua
return {
  {
    id = "win.1",
    title = "Opening Splits",
    help_tag = "opening-window",  -- optional; used by :CoachHelp
    actions = {
      { action = "<C-w>s", display = "Ctrl-W s", desc = "Split horizontally" },
      -- ...
    },
  },
  -- more chapters...
}
```

The `action` field must match exactly what
[track-action.nvim](https://github.com/17xande/track-action.nvim) emits. Ex-commands
use the `ex:` prefix (e.g. `ex:jumps`).
