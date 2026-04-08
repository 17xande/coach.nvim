# Neovim User Manual - Chapter Extraction

Source: `usr_02.txt` - **The first steps in Vim**

> "This chapter provides just enough information to edit a file with Vim.
> Not well or fast, but you can edit. Take some time to practice with these
> commands, they form the base for what follows."

---

## 02.1 - Running Vim for the First Time

No keybindings taught. Introduces the concept of opening a file (`nvim file.txt`), the blank window, tilde (`~`) lines, and the message line.

---

## 02.2 - Inserting text

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

| Key  | Action                                      |
|------|---------------------------------------------|
| `x`  | Delete character under cursor               |
| `dd` | Delete entire line                          |
| `J`  | Join lines (delete the line break between them) |

---

## 02.5 - Undo and Redo

| Key      | Action                                  |
|----------|-----------------------------------------|
| `u`      | Undo last edit                          |
| `CTRL-R` | Redo (reverse the undo)                 |
| `U`      | Undo all changes on the last edited line |

Notes: `u` undoes one change at a time (granular). `U` is itself a change that can be undone with `u`.

---

## 02.6 - Other editing commands

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

| Key    | Action                              |
|--------|-------------------------------------|
| `ZZ`   | Write (save) the file and exit      |
| `:q!`  | Quit without saving (discard changes) |
| `:e!`  | Reload the original version of the file |

---

## 02.8 - Finding help

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
