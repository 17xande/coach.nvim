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
| `exercises/04-anti-arrow-keys.lua` | Anti-pattern drills with `negatives` to punish bad habits |

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

### Negative triggers

A chapter may also declare a `negatives` list. Each entry is shaped like an
action, but pressing it **decrements** every positive action's count for that
chapter (floored at zero). Use it to punish bad habits — e.g. mark `l` and
`<Right>` as negatives in a `w`/`W` chapter so reaching for arrow keys eats
your progress.

```lua
{
  id = "anti.word",
  title = "Word Movement (no h/l spam!)",
  actions = {
    { action = "w", display = "w", desc = "Word forward" },
    { action = "W", display = "W", desc = "WORD forward" },
  },
  negatives = {
    -- Decrement only after 4 consecutive `l` presses.
    { action = "l", display = "l", desc = "Use w/W instead", threshold = 4 },
    -- Any counted `l` (4l, 12l, …) decrements immediately.
    { action = "[count]l", display = "{N}l", desc = "Lazy jump" },
    -- Arrow key: zero tolerance.
    { action = "<Right>", display = "→", desc = "No arrow keys" },
  },
}
```

**Threshold.** A negative entry may set `threshold = N` (default `1`). The
decrement only fires after N *consecutive* presses of that exact action.
Pressing anything else — a positive action, a different negative, an
unrelated key — resets the streak.

**Action format.** Action strings follow track-action.nvim's emit format. A
plain `"l"` matches `l` only. To match counted forms like `4l` or `12l`, use
the literal string `"[count]l"` — track-action strips the count and prefixes
`[count]` to distinguish from the uncounted variant.
