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
- 🎒 **Custom exercise sets** — add your own volumes from a local directory or clone them straight from a GitHub repo
- 💾 **Per-volume progress** — switch between volumes without mixing up your progress
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

  -- root directory for per-volume progress files
  progress_dir = vim.fn.stdpath("data") .. "/coach/progress",

  -- exercise sets (see "Sets and volumes" below)
  sets = {
    { name = "neovim-manual" },  -- builtin, always included automatically
  },

  -- optional: "set/volume" to start on (otherwise last-used is remembered)
  active = "neovim-manual/01-first-steps",

  -- keybinds (set any to false to disable)
  keybinds = {
    toggle = "<leader>kk",  -- start / stop coaching
    window = "<leader>kw",  -- toggle the floating window
    next   = "<leader>kn",  -- advance to the next exercise (only when complete)
    prev   = "<leader>kp",  -- go back to the previous exercise
    skip   = "<leader>ks",  -- skip the current exercise regardless of progress
    help   = "<leader>kh",  -- open :help for the current exercise
    index  = "<leader>ki",  -- toggle the exercise index sidebar
    volume = "<leader>kv",  -- open the volume picker
  },
})
```

Individual exercises can override `required_reps` in their definition, so some
drills may require more or fewer reps than the global setting.

## 🎒 Sets and volumes

An **exercise set** is a source of **volumes**. Each volume is a single Lua
file made up of one or more **chapters** (an ordered list of related
key-press drills). Only one volume is active at a time, and each volume keeps
its own progress file — so switching between, say, the Neovim manual and your
own fold drills doesn't mix up your rep counts.

### Sources

Each set entry has a `name` and an optional `source`:

```lua
require("coach").setup({
  sets = {
    { name = "neovim-manual" },                                -- builtin
    { name = "mine",  source = "~/dotfiles/coach-volumes" },   -- local directory
    { name = "pack",  source = "github:17xande/exercises.nvim" }, -- github repo
  },
})
```

- **builtin** — omit `source` (or use `"builtin"`). Ships with coach.nvim,
  split into six volumes by Neovim-user-manual chapter range.
- **local directory** — every `*.lua` file in the directory is a volume;
  the filename (without extension) becomes the volume name.
- **GitHub repo** — `source = "github:owner/repo"` (optionally
  `@ref`/`@branch`). On first `setup()`, coach.nvim clones the repo in the
  background to `stdpath("data") .. "/coach/sets/<set-name>/"` and then
  reads `*.lua` volume files from its `exercises/` directory. Use
  `:CoachUpdate <set>` to `git pull` later.

### Volume file format

Each volume file returns a list of chapter tables:

```lua
-- my-volume.lua
return {
  {
    id = "win.1",
    title = "Horizontal splits",
    help_tag = "opening-window",  -- optional; used by :CoachHelp
    required_reps = 10,           -- optional override for this chapter only
    actions = {
      { action = "<C-w>s", display = "Ctrl-W s", desc = "Split below" },
      { action = "<C-w>q", display = "Ctrl-W q", desc = "Close window" },
    },
  },
  -- more chapters...
}
```

The `action` string must match what
[track-action.nvim](https://github.com/17xande/track-action.nvim) emits.
Ex-commands use the `ex:` prefix (e.g. `ex:jumps`). Chapter ids must be
unique within a volume.

An example volume set lives in [`examples/exercises/`](examples/exercises) —
you can push those three files to a GitHub repo (or point a local set at
them) to test the loader end-to-end.

### Commands

| Command | Description |
| --- | --- |
| `:CoachVolume [set/volume]` | Switch the active volume. No argument opens a picker. |
| `:CoachSet [set]` | Switch to the first volume of a set. |
| `:CoachUpdate [set]` | `git pull` a GitHub-sourced set (no argument updates all). |

Tab completion is available for all three.

### Progress layout

Progress is stored per volume at:

```
{progress_dir}/{set_name}/{volume_name}.json
```

The active `set/volume` pointer is persisted separately at
`{stdpath("data")}/coach/state.json` so coach.nvim remembers what you were
working on between sessions.

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
| `:CoachVolume [set/volume]` | Switch the active volume (picker when no argument) |
| `:CoachSet [set]` | Switch to the first volume of a set |
| `:CoachUpdate [set]` | `git pull` a GitHub-sourced set |

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

Progress for each volume is persisted as JSON at
`{stdpath("data")}/coach/progress/{set_name}/{volume_name}.json`:

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

The `set/volume` you were last on is stored in
`{stdpath("data")}/coach/state.json`. GitHub-sourced sets are cached under
`{stdpath("data")}/coach/sets/{set_name}/`.

Progress is saved when you advance to a new exercise, when you switch volumes,
and when Neovim exits.

## 📄 License

Licensed under the [MIT License](LICENSE).
