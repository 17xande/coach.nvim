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
