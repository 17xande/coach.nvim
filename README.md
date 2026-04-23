# 🎓 coach.nvim

A Neovim plugin that coaches you through the Neovim user manual — one exercise at a time.
It tracks which keys you actually press, measures your reps against structured exercises
extracted from the manual, and nudges you forward once you've built real muscle memory.

## ✨ Features

- 📖 **Structured exercises** — lessons drawn directly from the Neovim user manual, ordered by topic
- 🔢 **Rep counting** — each action must be pressed a configurable number of times before you can advance
- 🪟 **Live floating window** — a non-intrusive panel that shows your progress bars and action status as you work
- 🚫 **Shadow detection** — if you've remapped a key (e.g. `gd` for LSP), coach.nvim knows and won't count it or block your progress
- 📋 **Exercise index sidebar** — browse all exercises at a glance and jump to any one directly
- 💾 **Persistent progress** — your rep counts and current exercise survive restarts
- 🔗 **Powered by track-action.nvim** — delegates all keystroke interception and grammar parsing to a dedicated plugin

## ⚡️ Requirements

- Neovim >= 0.9.0
- [track-action.nvim](https://github.com/17xande/track-action.nvim) — required for keystroke tracking

## 📦 Installation

Install both plugins with your preferred package manager:

```lua
-- lazy.nvim
{
  "17xande/coach.nvim",
  event = "VeryLazy",
  dependencies = { "17xande/track-action.nvim" },
  opts = {},
},
```

<details><summary>packer.nvim</summary>

```lua
use {
  "17xande/coach.nvim",
  requires = { "17xande/track-action.nvim" },
  config = function()
    require("coach").setup()
  end,
}
```

</details>

If track-action.nvim is missing, coach.nvim will log an error and coaching will not start,
but the plugin itself will load without error.

## ⚙️ Configuration

**coach.nvim** comes with the following defaults:

```lua
require("coach").setup({
  -- reps required per action before an exercise is considered complete
  required_reps = 20,

  -- where progress is persisted
  progress_file = vim.fn.stdpath("data") .. "/coach_progress.json",

  -- keybinds (set any to false to disable)
  keybinds = {
    toggle = "<leader>kk",  -- start / stop coaching
    window = "<leader>kw",  -- toggle the floating window
    next   = "<leader>kn",  -- advance to the next exercise (only when complete)
    prev   = "<leader>kp",  -- go back to the previous exercise
    skip   = "<leader>ks",  -- skip the current exercise regardless of progress
    help   = "<leader>kh",  -- open :help for the current exercise
    index  = "<leader>ki",  -- toggle the exercise index sidebar
  },
})
```

Individual exercises can override `required_reps` in their definition, so some
drills may require more or fewer reps than the global setting.

## 🚀 Usage

| Command | Description |
| --- | --- |
| `:CoachToggle` | Start or stop coaching |
| `:CoachWindow` | Toggle the floating progress window |
| `:CoachNext` | Advance to the next exercise (only when current is complete) |
| `:CoachPrev` | Go back to the previous exercise |
| `:CoachSkip` | Skip the current exercise regardless of completion |
| `:CoachHelp` | Open `:help` for the current exercise topic |
| `:CoachIndex` | Toggle the exercise index sidebar |

Once coaching is started, the floating window appears in the corner of your editor.
It shows each action in the current exercise, a progress bar, and a rep count. Keys
you've remapped are shown with a shadow indicator and skipped for completion.

Pressing the same key repeatedly in quick succession won't count — coach.nvim
detects spam via a ring buffer and reminds you to use the key in context.

## 🗂️ Exercise index

`:CoachIndex` opens a sidebar listing every exercise with status icons:

| Icon | Meaning |
| --- | --- |
| `▶` | Current exercise |
| `✓` | Completed |
| `●` | In progress |
| ` ` | Not started |

Press `<CR>` on any entry to jump directly to that exercise.

## 💾 Storage

Progress is persisted as JSON at `~/.local/share/nvim/coach_progress.json`:

```json
{
  "current_exercise_index": 3,
  "welcome_shown": true,
  "exercises": {
    "02.2": { "i": 20 },
    "03.1": { "w": 12, "ge": 5 }
  }
}
```

Progress is saved when you advance to a new exercise and when Neovim exits.

## 📄 License

Licensed under the [MIT License](LICENSE).
