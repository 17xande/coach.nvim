# Neovim User Manual - Chapter Extraction

Source: `usr_02.txt` - **The first steps in Vim**

> "This chapter provides just enough information to edit a file with Vim.
> Not well or fast, but you can edit. Take some time to practice with these
> commands, they form the base for what follows."

---

## 02.1 - Running Vim for the First Time
<!-- help: 02.1 | :h 02.1 -->

No keybindings taught. Introduces the concept of opening a file (`nvim file.txt`), the blank window, tilde (`~`) lines, and the message line.

---

## 02.2 - Inserting text
<!-- help: 02.2 | :h 02.2 -->

Introduces the concept of **modal editing** (Normal mode vs Insert mode).

| Key     | Mode   | Action                          |
|---------|--------|---------------------------------|
| `i`     | Normal | Enter Insert mode (before cursor) |
| `<Esc>` | Insert | Return to Normal mode           |

Also introduces:
- `:set showmode` (command-line command to display current mode)
- The concept of pressing `<Esc>` to escape any mode back to Normal mode

---

## 02.3 - Moving around
<!-- help: 02.3 | :h 02.3 -->

Basic cursor movement (Normal mode).

| Key | Action     |
|-----|------------|
| `h` | Move left  |
| `j` | Move down  |
| `k` | Move up    |
| `l` | Move right |

Notes: The manual explicitly discourages arrow keys in favor of `hjkl` for speed.

---

## 02.4 - Deleting characters
<!-- help: 02.4 | :h 02.4 -->

| Key  | Action                                      |
|------|---------------------------------------------|
| `x`  | Delete character under cursor               |
| `dd` | Delete entire line                          |
| `J`  | Join lines (delete the line break between them) |

---

## 02.5 - Undo and Redo
<!-- help: 02.5 | :h 02.5 -->

| Key      | Action                                  |
|----------|-----------------------------------------|
| `u`      | Undo last edit                          |
| `CTRL-R` | Redo (reverse the undo)                 |
| `U`      | Undo all changes on the last edited line |

Notes: `u` undoes one change at a time (granular). `U` is itself a change that can be undone with `u`.

---

## 02.6 - Other editing commands
<!-- help: 02.6 | :h 02.6 -->

### Appending

| Key | Mode   | Action                                   |
|-----|--------|------------------------------------------|
| `a` | Normal | Enter Insert mode *after* the cursor     |

### Opening new lines

| Key | Mode   | Action                                        |
|-----|--------|-----------------------------------------------|
| `o` | Normal | Open new line *below* cursor, enter Insert mode |
| `O` | Normal | Open new line *above* cursor, enter Insert mode |

### Using a count

Not a keybinding itself, but a modifier concept: any command can be preceded by a number to repeat it.

| Example    | Effect                                |
|------------|---------------------------------------|
| `3x`       | Delete 3 characters                   |
| `9k`       | Move up 9 lines                       |
| `3a!<Esc>` | Append `!` three times                |

---

## 02.7 - Getting out
<!-- help: 02.7 | :h 02.7 -->

| Key    | Action                              |
|--------|-------------------------------------|
| `ZZ`   | Write (save) the file and exit      |
| `:q!`  | Quit without saving (discard changes) |
| `:e!`  | Reload the original version of the file |

---

## 02.8 - Finding help
<!-- help: 02.8 | :h 02.8 -->

| Key / Command       | Action                                    |
|---------------------|-------------------------------------------|
| `:help`             | Open the general help window              |
| `<F1>`              | Open the general help window (alternative)|
| `:help {subject}`   | Open help for a specific subject          |
| `CTRL-]`            | Jump to tag (follow hyperlink in help)    |
| `CTRL-T`            | Pop tag (go back after following a link)  |
| `CTRL-O`            | Jump to older position (also goes back)   |

---

## Summary of all keybindings/actions taught in Chapter 02

### Mode switching
- `i` - enter Insert mode (before cursor)
- `a` - enter Insert mode (after cursor)
- `o` - open line below, enter Insert mode
- `O` - open line above, enter Insert mode
- `<Esc>` - return to Normal mode

### Cursor movement
- `h` - left
- `j` - down
- `k` - up
- `l` - right

### Editing
- `x` - delete character
- `dd` - delete line
- `J` - join lines

### Undo / Redo
- `u` - undo
- `CTRL-R` - redo
- `U` - undo all changes on line

### Saving and quitting
- `ZZ` - save and quit
- `:q!` - quit without saving
- `:e!` - reload file

### Help navigation
- `:help` / `<F1>` - open help
- `:help {subject}` - topic help
- `CTRL-]` - follow link
- `CTRL-T` - go back
- `CTRL-O` - jump to older position

### Concepts (not keybindings)
- Modal editing (Normal vs Insert mode)
- Count prefix (`{count}{command}`) to repeat any command

---
---

# Neovim User Manual - Chapter 03 Extraction

Source: `usr_03.txt` - **Moving around**

> "Before you can insert or delete text the cursor has to be moved to the right
> place. Vim has a large number of commands to position the cursor. This
> chapter shows you how to use the most important ones."

---

## 03.1 - Word movement
<!-- help: 03.1 | :h 03.1 -->

| Key  | Action                                  |
|------|-----------------------------------------|
| `w`  | Move forward to start of next word      |
| `b`  | Move backward to start of previous word |
| `e`  | Move forward to end of word             |
| `ge` | Move backward to end of previous word   |

WORD variants (whitespace-separated, ignore punctuation):

| Key  | Action                        |
|------|-------------------------------|
| `W`  | Forward to start of next WORD |
| `B`  | Backward to start of prev WORD|
| `E`  | Forward to end of WORD        |
| `gE` | Backward to end of prev WORD  |

---

## 03.2 - Moving to the start or end of a line
<!-- help: 03.2 | :h 03.2 -->

| Key | Action                                    |
|-----|-------------------------------------------|
| `0` | Move to first character of line           |
| `^` | Move to first non-blank character of line |
| `$` | Move to end of line                       |

---

## 03.3 - Moving to a character
<!-- help: 03.3 | :h 03.3 -->

| Key  | Action                                           |
|------|--------------------------------------------------|
| `f{char}` | Find char forward (on the character)        |
| `F{char}` | Find char backward (on the character)       |
| `t{char}` | Till char forward (one char before)          |
| `T{char}` | Till char backward (one char after)          |
| `;`  | Repeat last f/F/t/T forward                      |
| `,`  | Repeat last f/F/t/T backward                     |

---

## 03.4 - Matching a parenthesis
<!-- help: 03.4 | :h 03.4 -->

| Key | Action                                            |
|-----|---------------------------------------------------|
| `%` | Jump to matching parenthesis/bracket/brace        |

Works for `()`, `[]`, and `{}` pairs.

---

## 03.5 - Moving to a specific line
<!-- help: 03.5 | :h 03.5 -->

| Key    | Action                               |
|--------|--------------------------------------|
| `gg`   | Go to first line of file             |
| `G`    | Go to last line of file              |
| `{n}G` | Go to line n (e.g. `33G`)            |
| `H`    | Move to top of visible screen        |
| `M`    | Move to middle of visible screen     |
| `L`    | Move to bottom of visible screen     |

Notes: `{n}%` moves to that percentage of the file (e.g. `50%` = halfway).

---

## 03.6 - Telling where you are
<!-- help: 03.6 | :h 03.6 -->

| Key / Command  | Action                              |
|----------------|-------------------------------------|
| `CTRL-G`       | Show file info and cursor position  |
| `:set number`  | Show line numbers                   |
| `:set ruler`   | Show cursor position in status line |

Notes: No trackable normal-mode actions for exercises. Informational section.

---

## 03.7 - Scrolling around
<!-- help: 03.7 | :h 03.7 -->

| Key      | Action                              |
|----------|-------------------------------------|
| `CTRL-U` | Scroll up half a screen             |
| `CTRL-D` | Scroll down half a screen           |
| `CTRL-B` | Scroll up a full screen             |
| `CTRL-F` | Scroll down a full screen           |
| `CTRL-E` | Scroll up one line                  |
| `CTRL-Y` | Scroll down one line                |
| `zz`     | Center cursor line on screen        |
| `zt`     | Put cursor line at top of screen    |
| `zb`     | Put cursor line at bottom of screen |

---

## 03.8 - Simple searches
<!-- help: 03.8 | :h 03.8 -->

| Key  | Action                                    |
|------|-------------------------------------------|
| `/`  | Search forward (type pattern, press Enter) |
| `?`  | Search backward                           |
| `n`  | Repeat search in same direction           |
| `N`  | Repeat search in opposite direction       |
| `*`  | Search forward for word under cursor      |
| `#`  | Search backward for word under cursor     |

---

## 03.9 - Simple search patterns
<!-- help: 03.9 | :h 03.9 -->

No new keybindings. Teaches regex basics for search patterns:
- `^` matches beginning of line
- `$` matches end of line
- `.` matches any single character
- `\` escapes special characters

---

## 03.10 - Using marks
<!-- help: 03.10 | :h 03.10 -->

| Key           | Action                                     |
|---------------|--------------------------------------------|
| `` ` ``       | Jump back to position before last jump     |
| `CTRL-O`      | Jump to older position in jump list        |
| `CTRL-I`      | Jump to newer position in jump list        |
| `m{a-z}`      | Set mark {a-z} at cursor position          |
| `` `{a-z} ``  | Jump to mark {a-z}                         |
| `'{a-z}`      | Jump to start of line containing mark      |

Notes: `CTRL-I` is the same as `<Tab>`.

---

## Summary of all keybindings/actions taught in Chapter 03

### Word movement
- `w` - word forward
- `b` - word backward
- `e` - word end forward
- `ge` - word end backward
- `W`, `B`, `E`, `gE` - WORD variants

### Line position
- `0` - line start
- `^` - first non-blank
- `$` - line end

### Character search
- `f{char}` - find forward
- `F{char}` - find backward
- `t{char}` - till forward
- `T{char}` - till backward
- `;` - repeat find forward
- `,` - repeat find backward

### Matching
- `%` - matching bracket

### Line/screen movement
- `gg` - first line
- `G` - last line / go to line n
- `H` - screen top
- `M` - screen middle
- `L` - screen bottom

### Scrolling
- `CTRL-U` / `CTRL-D` - half screen up/down
- `CTRL-B` / `CTRL-F` - full screen up/down
- `CTRL-E` / `CTRL-Y` - one line up/down
- `zz` / `zt` / `zb` - center/top/bottom cursor

### Searching
- `/` - search forward
- `?` - search backward
- `n` / `N` - next/prev match
- `*` / `#` - search word under cursor forward/backward

### Marks and jumps
- `` ` `` - jump back to before last jump
- `CTRL-O` / `CTRL-I` - older/newer jump
- `m{a-z}` - set mark
- `` `{a-z} `` / `'{a-z}` - go to mark

---
---

# Neovim User Manual - Chapter 04 Extraction

Source: `usr_04.txt` - **Making small changes**

> "This chapter shows you several ways of making corrections and moving text
> around. It teaches you the three basic ways to change text: operator-motion,
> Visual mode and text objects."

---

## 04.1 - Operators and motions
<!-- help: 04.1 | :h 04.1 -->

Introduces the **operator-motion** pattern: an operator (`d`, `c`, `y`) followed by a motion.

| Key  | Action                              |
|------|-------------------------------------|
| `dw` | Delete from cursor to next word     |
| `d$` | Delete from cursor to end of line   |

Notes: The key concept is that `d` can be combined with any motion command.
Counts work with both operator and motion: `d4w`, `3dw`, `3d2w`.

---

## 04.2 - Changing text
<!-- help: 04.2 | :h 04.2 -->

The `c` (change) operator: deletes text and enters Insert mode.

| Key  | Action                              |
|------|-------------------------------------|
| `cc` | Change entire line                  |
| `r`  | Replace character under cursor      |
| `s`  | Substitute character (delete + insert) |
| `S`  | Substitute line (same as `cc`)      |
| `C`  | Change to end of line (same as `c$`)|
| `D`  | Delete to end of line (same as `d$`)|
| `X`  | Delete character before cursor      |

Shortcuts summary:
- `x` = `dl`, `X` = `dh`, `D` = `d$`
- `C` = `c$`, `s` = `cl`, `S` = `cc`

---

## 04.3 - Repeating a change
<!-- help: 04.3 | :h 04.3 -->

| Key | Action                                |
|-----|---------------------------------------|
| `.` | Repeat the last change command        |

Notes: Works for all changes except `u`, `CTRL-R`, and `:` commands.

---

## 04.4 - Visual mode
<!-- help: 04.4 | :h 04.4 -->

| Key      | Action                            |
|----------|-----------------------------------|
| `v`      | Start Visual mode (character)     |
| `V`      | Start Visual mode (line)          |
| `CTRL-V` | Start Visual mode (block)         |

Notes: Select text visually, then apply an operator (`d`, `c`, `y`, etc.).
`o` in Visual mode jumps to the other end of selection.

---

## 04.5 - Moving text
<!-- help: 04.5 | :h 04.5 -->

| Key | Action                                |
|-----|---------------------------------------|
| `p` | Put (paste) after cursor              |
| `P` | Put (paste) before cursor             |

Notes: Deleted/yanked text goes into a register. `p`/`P` paste from it.
`xp` swaps two characters (delete char, put after).

---

## 04.6 - Copying text
<!-- help: 04.6 | :h 04.6 -->

| Key  | Action                              |
|------|-------------------------------------|
| `yy` | Yank (copy) entire line             |
| `Y`  | Yank to end of line                 |

Notes: `y` is an operator, so `yw` yanks a word, `y2w` yanks two words, etc.

---

## 04.7 - Using the clipboard
<!-- help: 04.7 | :h 04.7 -->

| Key     | Action                              |
|---------|-------------------------------------|
| `"*yy`  | Yank line to system clipboard       |
| `"*p`   | Put from system clipboard           |

Notes: Register `"*` accesses the system clipboard. GUI/clipboard-specific section.

---

## 04.8 - Text objects
<!-- help: 04.8 | :h 04.8 -->

Introduces **operator + text object** pattern:

| Key   | Action                                  |
|-------|-----------------------------------------|
| `daw` | Delete a word (including whitespace)    |
| `diw` | Delete inner word (word only)           |
| `cis` | Change inner sentence                   |
| `das` | Delete a sentence (including whitespace)|

Notes: Text objects work from anywhere inside the object, unlike motions.
Pattern: `{operator}{a/i}{object}` where `a` = "a" (includes surrounding), `i` = "inner".

---

## 04.9 - Replace mode
<!-- help: 04.9 | :h 04.9 -->

| Key | Action                                |
|-----|---------------------------------------|
| `R` | Enter Replace mode (overtype)         |

Notes: Each character typed replaces the one under cursor. `<BS>` restores original.

---

## 04.10 - Conclusion
<!-- help: 04.10 | :h 04.10 -->

Additional commands mentioned:

| Key | Action                                       |
|-----|----------------------------------------------|
| `~` | Toggle case of character under cursor        |
| `I` | Insert at first non-blank of line            |
| `A` | Append at end of line                        |

---

## Summary of all keybindings/actions taught in Chapter 04

### Operator-motion combos
- `dw` - delete word
- `d$` - delete to end of line

### Change operator and shortcuts
- `cc` - change line
- `C` - change to end of line
- `D` - delete to end of line
- `s` - substitute character
- `S` - substitute line
- `X` - delete char before cursor
- `r` - replace character

### Repeat
- `.` - repeat last change

### Visual mode
- `v` - visual character
- `V` - visual line
- `CTRL-V` - visual block

### Put (paste)
- `p` - put after
- `P` - put before

### Yank (copy)
- `yy` - yank line
- `Y` - yank to end of line

### Text objects (with operators)
- `daw` / `diw` - delete a/inner word
- `cis` / `das` - change inner / delete a sentence

### Other
- `~` - toggle case
- `I` - insert at line start
- `A` - append at line end
- `R` - replace mode

---
---

# Neovim User Manual - Chapter 07 Extraction

Source: `usr_07.txt` - **Editing more than one file**

---

## 07.1 - Edit another file
<!-- help: 07.1 | :h 07.1 -->

No trackable normal-mode keybindings. Covers `:edit`, `:write`, `:hide edit`.

---

## 07.2 - A list of files
<!-- help: 07.2 | :h 07.2 -->

No trackable normal-mode keybindings. Covers `:next`, `:previous`, `:last`, `:first`, `:args`.

---

## 07.3 - Jumping from file to file
<!-- help: 07.3 | :h 07.3 -->

| Key    | Action                                     |
|--------|--------------------------------------------|
| `CTRL-^` | Jump to alternate (previously edited) file |
| `` `" `` | Jump to position where cursor was when left file |
| `` `. `` | Jump to position of last change in file    |

Notes: `CTRL-^` is the primary key here — fast toggle between two files.
`` `" `` and `` `. `` are predefined marks; they use the `` ` `` command already covered in 03.10.

---

## 07.4 - Backup files
<!-- help: 07.4 | :h 07.4 -->

No trackable keybindings. Covers `set backup`, `set backupext`, `set patchmode`.

---

## 07.5 - Copy text between files
<!-- help: 07.5 | :h 07.5 -->

No new keybindings. Uses commands already covered (Visual mode, `y`, `p`, registers).
Introduces named registers (`"fyas`, `"l3yy`, `"fp`) — register-prefix syntax extends existing yank/put commands.

---

## 07.6 - Viewing a file
<!-- help: 07.6 | :h 07.6 -->

No trackable normal-mode keybindings. Covers `vim -R` and `vim -M` read-only modes.

---

## 07.7 - Changing the file name
<!-- help: 07.7 | :h 07.7 -->

No trackable keybindings. Covers `:saveas`, `:file`.

---

## Summary for Chapter 07

| Exercise | Section | Actions |
|----------|---------|---------|
| 1 | 07.3 | `<C-^>` |

---
---

# Neovim User Manual - Chapter 08 Extraction

Source: `usr_08.txt` - **Splitting windows**

---

## 08.1 - Split a window
<!-- help: 08.1 | :h 08.1 -->

| Key        | Action                               |
|------------|--------------------------------------|
| `CTRL-W w` | Move to next window (cycle)          |

Notes: `:split` opens a second window. `CTRL-W w` (or `CTRL-W CTRL-W`) cycles between them.

---

## 08.2 - Split a window on another file
<!-- help: 08.2 | :h 08.2 -->

No new trackable keybindings. `:split file`, `:new` are Ex commands.

---

## 08.3 - Window size
<!-- help: 08.3 | :h 08.3 -->

| Key        | Action                               |
|------------|--------------------------------------|
| `CTRL-W +` | Increase window height               |
| `CTRL-W -` | Decrease window height               |
| `CTRL-W _` | Maximize window height               |
| `CTRL-W =` | Make all windows equal size          |

---

## 08.4 - Vertical splits
<!-- help: 08.4 | :h 08.4 -->

| Key        | Action                               |
|------------|--------------------------------------|
| `CTRL-W h` | Move to window on the left           |
| `CTRL-W j` | Move to window below                 |
| `CTRL-W k` | Move to window above                 |
| `CTRL-W l` | Move to window on the right          |
| `CTRL-W t` | Move to TOP window                   |
| `CTRL-W b` | Move to BOTTOM window                |

---

## 08.5 - Moving windows
<!-- help: 08.5 | :h 08.5 -->

| Key        | Action                               |
|------------|--------------------------------------|
| `CTRL-W K` | Move window to top (full width)      |
| `CTRL-W J` | Move window to bottom (full width)   |
| `CTRL-W H` | Move window to far left (full height)|
| `CTRL-W L` | Move window to far right (full height)|

---

## 08.6 - Commands for all windows
<!-- help: 08.6 | :h 08.6 -->

No trackable normal-mode keybindings. Covers `:qall`, `:wall`, `:wqall`.

---

## 08.7 - Viewing differences with diff mode
<!-- help: 08.7 | :h 08.7 -->

| Key  | Action                                  |
|------|-----------------------------------------|
| `]c` | Jump to next change (in diff mode)      |
| `[c` | Jump to previous change (in diff mode)  |
| `dp` | Diff put — push change to other window  |
| `do` | Diff obtain — pull change from other window |

---

## 08.8 - Various
<!-- help: 08.8 | :h 08.8 -->

No new trackable keybindings. Mentions `CTRL-^` splits (already covered), modifier commands.

---

## 08.9 - Tab pages
<!-- help: 08.9 | :h 08.9 -->

| Key  | Action                                  |
|------|-----------------------------------------|
| `gt` | Go to next tab page                     |
| `gT` | Go to previous tab page                 |

---

## Summary for Chapter 08

| Exercise | Section | Actions |
|----------|---------|---------|
| 1 | 08.1 / 08.4 | `<C-w>w`, `<C-w>h`, `<C-w>j`, `<C-w>k`, `<C-w>l` |
| 2 | 08.7 | `]c`, `[c`, `dp`, `do` |
| 3 | 08.9 | `gt`, `gT` |
