# Example coach.nvim sessions

This directory contains a small set of example **sessions** you can use to test
coach.nvim's custom-source loading. Each `.lua` file here is one session made
up of multiple sets.

## Sessions

| File | Topic |
| --- | --- |
| `01-windows.lua` | Window splits, navigation, resizing |
| `02-marks-and-jumps.lua` | Marks, jump list, change list |
| `03-folds.lua` | Manual folds: create, toggle, navigate |
| `04-anti-arrow-keys.lua` | Anti-pattern drills with `negatives` to punish bad habits |

## Testing a local directory source

Point a program at this directory directly:

```lua
require("coach").setup({
  programs = {
    { name = "neovim-manual" },
    { name = "extras", source = "~/dev/coach.nvim/exercise-programs/examples" },
  },
})
```

Then `:CoachSession extras/01-windows` to switch.

## Testing a GitHub source

1. Create a new GitHub repo (e.g. `you/coach-extras`).
2. Copy these `.lua` files to the root (or any subdir) of that repo.
3. Push.
4. Configure coach.nvim:

   ```lua
   require("coach").setup({
     programs = {
       { name = "neovim-manual" },
       { name = "extras", source = "github:you/coach-extras" },
     },
   })
   ```

5. Start Neovim. coach.nvim will clone the repo in the background to
   `~/.local/share/nvim/coach/programs/extras/`.
6. `:CoachSession` to pick a session. Progress is saved per session at
   `~/.local/share/nvim/coach/progress/extras/<session>.json`.
7. Push a change to the repo, then `:CoachUpdate extras` to pull it.

## Session file format

Each session returns a list of set tables:

```lua
return {
  {
    id = "win.1",
    title = "Opening Splits",
    help_tag = "opening-window",  -- optional; used by :CoachHelp
    exercises = {
      { exercise = "<C-w>s", display = "Ctrl-W s", desc = "Split horizontally" },
      -- ...
    },
  },
  -- more sets...
}
```

The `exercise` field must match exactly what
[track-action.nvim](https://github.com/17xande/track-action.nvim) emits. Ex-commands
use the `ex:` prefix (e.g. `ex:jumps`).

### Negative triggers

A set may also declare a `negatives` list of **rules**. Each rule has
`triggers` (the bad-habit keys), `decrement` (which positive exercises get
their count lowered when the rule fires, floored at zero), and an optional
`message` shown in the floating window when it fires.

```lua
{
  id = "anti.word",
  title = "Word Movement (no h/l spam!)",
  exercises = {
    { exercise = "w", display = "w", desc = "Word forward" },
    { exercise = "W", display = "W", desc = "WORD forward" },
  },
  negatives = {
    {
      triggers  = { "[4]l", "[2]<Right>", "[count]l" },
      decrement = { "w", "W" },
      message   = "Use w/W instead of l",
    },
  },
}
```

**`[N]` prefix.** A trigger may carry an `[N]` prefix requiring N *consecutive*
presses of that exact action before the rule fires. Without a prefix, threshold
defaults to 1. The streak resets when any non-trigger action is seen (positives,
unrelated keys) or when a *different* trigger inside the same rule is pressed.

**Action format.** Trigger strings follow track-action.nvim's emit format. A
plain `"l"` matches `l` only. To match counted forms like `4l` or `12l`, use
the literal string `"[count]l"` — track-action strips the count and prefixes
`[count]` to distinguish from the uncounted variant. The two are independent
triggers; you can list both in the same rule's `triggers`.
