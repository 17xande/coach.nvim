# 🎓 coach.nvim

A Neovim plugin that coaches you through the Neovim user manual — one set at a time.
It tracks which keys you actually press, measures your reps against structured
exercises extracted from the manual, and nudges you forward once you've built real
muscle memory.

## ✨ Features

- 📖 **Structured sessions** — drills drawn directly from the Neovim user manual, ordered by topic
- 🔢 **Rep counting** — each exercise must be pressed a configurable number of times before you can advance
- 🪟 **Live floating window** — a non-intrusive panel that shows your progress bars and exercise status as you work
- 🚫 **Shadow detection** — if you've remapped a key (e.g. `gd` for LSP), coach.nvim knows and won't count it or block your progress
- 🗺️ **Your own mappings count** — press your `<leader>` binding for an exercise and it still credits the rep, with no configuration: Neovim reports both the command your mapping ran and the keys you pressed
- 📋 **Set index sidebar** — browse all sets at a glance and jump to any one directly
- 🎒 **Custom programs** — add your own sessions from a local directory or clone them straight from a GitHub repo
- 💾 **Per-session progress** — switch between sessions without mixing up your progress
- 🔗 **Powered by track-action.nvim** — all action tracking is delegated to a dedicated plugin

## ⚡️ Requirements

- Neovim >= 0.13 (needs the `CmdAtom` event)
- [track-action.nvim](https://github.com/17xande/track-action.nvim) — required for action tracking

0.13 is a hard requirement, not a recommendation: track-action reads your actions from
Neovim's `CmdAtom` event and has no fallback, so nothing is counted on an older
version. `:checkhealth coach` says so.

> **Note:** fifteen of the builtin exercises can never be credited, because Neovim
> reports the command that *ran* and for those keys that is not the key you pressed
> (`S` is reported as `cc`, `x` as `dl`, and starting a Visual selection reports
> nothing at all). They are labelled `unsupported` in the window and do not block a
> set. Five of them fill a *different* drill's bar — see `:help coach-unsupported`.

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
  -- reps required per exercise before a set is considered complete
  required_reps = 20,

  -- root directory for per-session progress files
  progress_dir = vim.fn.stdpath("data") .. "/coach/progress",

  -- exercise programs (see "Programs and sessions" below)
  programs = {
    { name = "user-manual" },  -- builtin, always included automatically
  },

  -- optional: "program/session" to start on (otherwise last-used is remembered)
  active = "user-manual/01-first-steps",

  -- keybinds (set any to false to disable)
  keybinds = {
    toggle  = "<leader>kk",  -- start / stop coaching
    window  = "<leader>kw",  -- toggle the floating window
    next    = "<leader>kn",  -- advance to the next set (only when complete)
    prev    = "<leader>kp",  -- go back to the previous set
    skip    = "<leader>ks",  -- skip the current set regardless of progress
    help    = "<leader>kh",  -- open :help for the current set
    index   = "<leader>ki",  -- toggle the set index sidebar
    session = "<leader>kS",  -- open the session picker
  },
})
```

Individual sets can override `required_reps` in their definition, so some
drills may require more or fewer reps than the global setting.

## 🎒 Programs and sessions

A **program** is a source of **sessions**. Each session is a single Lua file
made up of one or more **sets** (an ordered list of related key-press drills).
Each set contains one or more **exercises** (a single key with reps to
practise). Only one session is active at a time, and each session keeps its
own progress file — so switching between, say, the Neovim manual and your own
fold drills doesn't mix up your rep counts.

### Sources

Each program entry has a `name` and an optional `source`:

```lua
require("coach").setup({
  programs = {
    { name = "user-manual" },                                -- builtin
    { name = "mine",  source = "~/dotfiles/coach-sessions" },  -- local directory
    { name = "pack",  source = "github:17xande/exercises.nvim" }, -- github repo
  },
})
```

- **builtin** — omit `source` (or use `"builtin"`). Ships with coach.nvim,
  split into six sessions by Neovim-user-manual chapter range.
- **local directory** — every `*.lua` file in the directory is a session;
  the filename (without extension) becomes the session name.
- **GitHub repo** — `source = "github:owner/repo"` (optionally
  `@ref`/`@branch`). On first `setup()`, coach.nvim clones the repo in the
  background to `stdpath("data") .. "/coach/programs/<program-name>/"` and
  then reads `*.lua` session files from its root (or any immediate subdir).
  Use `:CoachUpdate <program>` to `git pull` later.

### Session file format

Each session file returns a list of set tables:

```lua
-- my-session.lua
return {
  {
    id = "win.1",
    title = "Horizontal splits",
    help_tag = "opening-window",  -- optional; used by :CoachHelp
    required_reps = 10,           -- optional override for this set only
    exercises = {
      { exercise = "<C-w>s", display = "Ctrl-W s", desc = "Split below" },
      { exercise = "<C-w>q", display = "Ctrl-W q", desc = "Close window" },
    },
  },
  -- more sets...
}
```

The `exercise` string must match what
[track-action.nvim](https://github.com/17xande/track-action.nvim) emits.
Ex-commands use the `ex:` prefix (e.g. `ex:jumps`). Set ids must be unique
within a session.

An example program lives in [`exercise-programs/examples/`](exercise-programs/examples)
— you can push those files to a GitHub repo (or point a local program at
them) to test the loader end-to-end.

### Commands

| Command | Description |
| --- | --- |
| `:CoachSession [program/session]` | Switch the active session. No argument opens a picker. |
| `:CoachProgram [program]` | Switch to the first session of a program. |
| `:CoachUpdate [program]` | `git pull` a GitHub-sourced program (no argument updates all). |

Tab completion is available for all three.

### Progress layout

Progress is stored per session at:

```
{progress_dir}/{program_name}/{session_name}.json
```

The active `program/session` pointer is persisted separately at
`{stdpath("data")}/coach/state.json` so coach.nvim remembers what you were
working on between sessions.

## 🚀 Usage

| Command | Description |
| --- | --- |
| `:CoachToggle` | Start or stop coaching |
| `:CoachWindow` | Toggle the floating progress window |
| `:CoachNext` | Advance to the next set (only when current is complete) |
| `:CoachPrev` | Go back to the previous set |
| `:CoachSkip` | Skip the current set regardless of completion |
| `:CoachHelp` | Open `:help` for the current set topic |
| `:CoachIndex` | Toggle the set index sidebar |
| `:CoachSession [program/session]` | Switch the active session (picker when no argument) |
| `:CoachProgram [program]` | Switch to the first session of a program |
| `:CoachUpdate [program]` | `git pull` a GitHub-sourced program |
| `:CoachStart` / `:CoachStop` | Start or stop coaching explicitly |
| `:CoachReset` | Clear progress for the current **set** |
| `:CoachResetSession` | Clear progress for the whole active **session** |
| `:CoachResetProgram[!]` | Clear progress for **every session** of the active program (prompts first; `!` skips the prompt) |

All three reset commands work whether or not coaching is currently running.

Once coaching is started, the floating window appears in the corner of your editor.
It shows each exercise in the current set, a progress bar, and a rep count. Keys
you've remapped are shown with a shadow indicator and skipped for completion.

Pressing the same key repeatedly in quick succession won't count — coach.nvim
detects spam via a ring buffer and reminds you to use the key in context.

## 🗂️ Set index

`:CoachIndex` opens a sidebar listing every set with status icons:

| Icon | Meaning |
| --- | --- |
| `▶` | Current set |
| `✓` | Completed |
| `●` | In progress |
| ` ` | Not started |

Press `<CR>` on any entry to jump directly to that set.

## 💾 Storage

Progress for each session is persisted as JSON at
`{stdpath("data")}/coach/progress/{program_name}/{session_name}.json`:

```json
{
  "current_set_index": 3,
  "welcome_shown": true,
  "sets": {
    "02.2": { "i": 20 },
    "03.1": { "w": 12, "ge": 5 }
  }
}
```

The `program/session` you were last on is stored in
`{stdpath("data")}/coach/state.json`. GitHub-sourced programs are cached under
`{stdpath("data")}/coach/programs/{program_name}/`.

Progress is saved when you advance to a new set, when you switch sessions,
and when Neovim exits.

## 📄 License

Licensed under the [MIT License](LICENSE).
