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

| Key     | Mode   | Action                          | Practice |
|---------|--------|---------------------------------|----------|
| `i`     | Normal | Enter Insert mode (before cursor) | ✓ |
| `<Esc>` | Insert | Return to Normal mode           | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:set showmode` | display current mode in the status line | ✗ |

---

## 02.3 - Moving around
<!-- help: 02.3 | :h 02.3 -->

Basic cursor movement (Normal mode).

| Key | Action     | Practice |
|-----|------------|----------|
| `h` | Move left  | ✓ |
| `j` | Move down  | ✓ |
| `k` | Move up    | ✓ |
| `l` | Move right | ✓ |

---

## 02.4 - Deleting characters
<!-- help: 02.4 | :h 02.4 -->

| Key  | Action                                      | Practice |
|------|---------------------------------------------|----------|
| `x`  | Delete character under cursor               | ✓ |
| `dd` | Delete entire line                          | ✓ |
| `J`  | Join lines (delete the line break between them) | ✓ |

---

## 02.5 - Undo and Redo
<!-- help: 02.5 | :h 02.5 -->

| Key      | Action                                  | Practice |
|----------|-----------------------------------------|----------|
| `u`      | Undo last edit                          | ✓ |
| `CTRL-R` | Redo (reverse the undo)                 | ✓ |
| `U`      | Undo all changes on the last edited line | ✓ |

---

## 02.6 - Other editing commands
<!-- help: 02.6 | :h 02.6 -->

### Appending

| Key | Mode   | Action                                   | Practice |
|-----|--------|------------------------------------------|----------|
| `a` | Normal | Enter Insert mode *after* the cursor     | ✓ |

### Opening new lines

| Key | Mode   | Action                                        | Practice |
|-----|--------|-----------------------------------------------|----------|
| `o` | Normal | Open new line *below* cursor, enter Insert mode | ✓ |
| `O` | Normal | Open new line *above* cursor, enter Insert mode | ✓ |

### Using a count

Not a keybinding itself, but a modifier concept: any command can be preceded by a number to repeat it.

---

## 02.7 - Getting out
<!-- help: 02.7 | :h 02.7 -->

| Key / Command | Action                              | Practice |
|---------------|-------------------------------------|----------|
| `ZZ`          | Write (save) the file and exit      | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:q!` | quit without saving (discard changes) | ✓ |
| `:q` | quit (fails if unsaved changes) | ✓ |
| `:e!` | reload the original version of the file | ✓ |

---

## 02.8 - Finding help
<!-- help: 02.8 | :h 02.8 -->

| Key       | Action                                    | Practice |
|-----------|-------------------------------------------|----------|
| `CTRL-]`  | Jump to tag (follow hyperlink in help)    | ✓ |
| `CTRL-T`  | Pop tag (go back after following a link)  | ✓ |
| `CTRL-O`  | Jump to older position (also goes back)   | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:help` | open the general help window | ✓ |
| `:help {subject}` | open help for a specific subject | ✓ |
| `:helpgrep {topic}` | search all help pages for a topic | ✓ |
| `:cnext` | go to next quickfix result | ✓ |
| `:copen` | open the quickfix window | ✓ |
| `:Tutor` | launch the interactive Vim tutorial | ✓ |

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
- `:q` - quit
- `:e!` - reload file

### Help navigation
- `:help` / `<F1>` - open help
- `:help {subject}` - topic help
- `:helpgrep {topic}` - search all help pages
- `:cnext` / `:copen` - quickfix navigation
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

| Key  | Action                                  | Practice |
|------|-----------------------------------------|----------|
| `w`  | Move forward to start of next word      | ✓ |
| `b`  | Move backward to start of previous word | ✓ |
| `e`  | Move forward to end of word             | ✓ |
| `ge` | Move backward to end of previous word   | ✓ |

WORD variants (whitespace-separated, ignore punctuation):

| Key  | Action                        | Practice |
|------|-------------------------------|----------|
| `W`  | Forward to start of next WORD | ✓ |
| `B`  | Backward to start of prev WORD| ✓ |
| `E`  | Forward to end of WORD        | ✓ |
| `gE` | Backward to end of prev WORD  | ✓ |

---

## 03.2 - Moving to the start or end of a line
<!-- help: 03.2 | :h 03.2 -->

| Key | Action                                    | Practice |
|-----|-------------------------------------------|----------|
| `0` | Move to first character of line           | ✓ |
| `^` | Move to first non-blank character of line | ✓ |
| `$` | Move to end of line                       | ✓ |

---

## 03.3 - Moving to a character
<!-- help: 03.3 | :h 03.3 -->

| Key  | Action                                           | Practice |
|------|--------------------------------------------------|----------|
| `f{char}` | Find char forward (on the character)        | ✓ |
| `F{char}` | Find char backward (on the character)       | ✓ |
| `t{char}` | Till char forward (one char before)          | ✓ |
| `T{char}` | Till char backward (one char after)          | ✓ |
| `;`  | Repeat last f/F/t/T forward                      | ✓ |
| `,`  | Repeat last f/F/t/T backward                     | ✓ |

---

## 03.4 - Matching a parenthesis
<!-- help: 03.4 | :h 03.4 -->

| Key | Action                                            | Practice |
|-----|---------------------------------------------------|----------|
| `%` | Jump to matching parenthesis/bracket/brace        | ✓ |

Works for `()`, `[]`, and `{}` pairs.

---

## 03.5 - Moving to a specific line
<!-- help: 03.5 | :h 03.5 -->

| Key    | Action                               | Practice |
|--------|--------------------------------------|----------|
| `gg`   | Go to first line of file             | ✓ |
| `G`    | Go to last line of file              | ✓ |
| `{n}G` | Go to line n (e.g. `33G`)            | ✓ |
| `{n}%` | Go to n% through file (e.g. `50%`)  | ✓ |
| `H`    | Move to top of visible screen        | ✓ |
| `M`    | Move to middle of visible screen     | ✓ |
| `L`    | Move to bottom of visible screen     | ✓ |

---

## 03.6 - Telling where you are
<!-- help: 03.6 | :h 03.6 -->

| Key / Command  | Action                              | Practice |
|----------------|-------------------------------------|----------|
| `CTRL-G`       | Show file info and cursor position  | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:set number` / `:set nonumber` | show/hide line numbers | ✗ |
| `:set ruler` | show cursor position in status line | ✗ |

---

## 03.7 - Scrolling around
<!-- help: 03.7 | :h 03.7 -->

| Key      | Action                              | Practice |
|----------|-------------------------------------|----------|
| `CTRL-U` | Scroll up half a screen             | ✓ |
| `CTRL-D` | Scroll down half a screen           | ✓ |
| `CTRL-B` | Scroll up a full screen             | ✓ |
| `CTRL-F` | Scroll down a full screen           | ✓ |
| `CTRL-E` | Scroll up one line                  | ✓ |
| `CTRL-Y` | Scroll down one line                | ✓ |
| `zz`     | Center cursor line on screen        | ✓ |
| `zt`     | Put cursor line at top of screen    | ✓ |
| `zb`     | Put cursor line at bottom of screen | ✓ |

---

## 03.8 - Simple searches
<!-- help: 03.8 | :h 03.8 -->

| Key  | Action                                    | Practice |
|------|-------------------------------------------|----------|
| `/`  | Search forward (type pattern, press Enter) | ✓ |
| `?`  | Search backward                           | ✓ |
| `n`  | Repeat search in same direction           | ✓ |
| `N`  | Repeat search in opposite direction       | ✓ |
| `*`  | Search forward for word under cursor      | ✓ |
| `#`  | Search backward for word under cursor     | ✓ |
| `g*` | Search forward for partial word under cursor | ✓ |
| `g#` | Search backward for partial word under cursor | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:set hlsearch` / `:set nohlsearch` | enable/disable search highlighting | ✗ |
| `:nohlsearch` | clear current highlights without changing option | ✓ |
| `:set ignorecase` / `:set noignorecase` | case-insensitive search | ✗ |
| `:set wrapscan` / `:set nowrapscan` | search wraps at file end | ✗ |
| `:set incsearch` / `:set noincsearch` | incremental search display | ✗ |

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

| Key           | Action                                     | Practice |
|---------------|--------------------------------------------|----------|
| `` ` ``       | Jump back to position before last jump     | ✓ |
| `''`          | Jump to start of line before last jump     | ✓ |
| `CTRL-O`      | Jump to older position in jump list        | ✓ |
| `CTRL-I`      | Jump to newer position in jump list        | ✓ |
| `m{a-z}`      | Set mark {a-z} at cursor position          | ✓ |
| `` `{a-z} ``  | Jump to mark {a-z}                         | ✓ |
| `'{a-z}`      | Jump to start of line containing mark      | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:jumps` | list the jump list | ✓ |
| `:marks` | list all marks | ✓ |

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
- `{n}%` - go to n% through file
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
- `g*` / `g#` - search partial word under cursor forward/backward

### Marks and jumps
- `` ` `` / `''` - jump back to before last jump (exact / line)
- `CTRL-O` / `CTRL-I` - older/newer jump
- `m{a-z}` - set mark
- `` `{a-z} `` / `'{a-z}` - go to mark

### Commands
- `:set hlsearch` / `:nohlsearch` - search highlighting
- `:set ignorecase` - case-insensitive search
- `:jumps` / `:marks` - list jumps/marks

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

| Key  | Action                              | Practice |
|------|-------------------------------------|----------|
| `dw` | Delete from cursor to next word     | ✓ |
| `d$` | Delete from cursor to end of line   | ✓ |

Notes: The key concept is that `d` can be combined with any motion command.
Counts work with both operator and motion: `d4w`, `3dw`, `3d2w`.

---

## 04.2 - Changing text
<!-- help: 04.2 | :h 04.2 -->

The `c` (change) operator: deletes text and enters Insert mode.

| Key  | Action                              | Practice |
|------|-------------------------------------|----------|
| `cc` | Change entire line                  | ✓ |
| `r`  | Replace character under cursor      | ✓ |
| `s`  | Substitute character (delete + insert) | ✓ |
| `S`  | Substitute line (same as `cc`)      | ✓ |
| `C`  | Change to end of line (same as `c$`)| ✓ |
| `D`  | Delete to end of line (same as `d$`)| ✓ |
| `X`  | Delete character before cursor      | ✓ |

Shortcuts summary:
- `x` = `dl`, `X` = `dh`, `D` = `d$`
- `C` = `c$`, `s` = `cl`, `S` = `cc`

---

## 04.3 - Repeating a change
<!-- help: 04.3 | :h 04.3 -->

| Key | Action                                | Practice |
|-----|---------------------------------------|----------|
| `.` | Repeat the last change command        | ✓ |

Notes: Works for all changes except `u`, `CTRL-R`, and `:` commands.

---

## 04.4 - Visual mode
<!-- help: 04.4 | :h 04.4 -->

| Key      | Action                            | Practice |
|----------|-----------------------------------|----------|
| `v`      | Start Visual mode (character)     | ✓ |
| `V`      | Start Visual mode (line)          | ✓ |
| `CTRL-V` | Start Visual mode (block)         | ✓ |

Notes: Select text visually, then apply an operator (`d`, `c`, `y`, etc.).
`o` in Visual mode jumps to the other end of selection.

---

## 04.5 - Moving text
<!-- help: 04.5 | :h 04.5 -->

| Key | Action                                | Practice |
|-----|---------------------------------------|----------|
| `p` | Put (paste) after cursor              | ✓ |
| `P` | Put (paste) before cursor             | ✓ |

Notes: Deleted/yanked text goes into a register. `p`/`P` paste from it.
`xp` swaps two characters (delete char, put after).

---

## 04.6 - Copying text
<!-- help: 04.6 | :h 04.6 -->

| Key  | Action                              | Practice |
|------|-------------------------------------|----------|
| `yy` | Yank (copy) entire line             | ✓ |
| `Y`  | Yank to end of line                 | ✓ |

Notes: `y` is an operator, so `yw` yanks a word, `y2w` yanks two words, etc.

---

## 04.7 - Using the clipboard
<!-- help: 04.7 | :h 04.7 -->

| Key     | Action                              | Practice |
|---------|-------------------------------------|----------|
| `"*yy`  | Yank line to system clipboard       | ✓ |
| `"*p`   | Put from system clipboard           | ✓ |
| `"+y`   | Yank to real clipboard (+ register) | ✓ |
| `"+p`   | Put from real clipboard             | ✓ |

Notes: Register `"*` accesses the system selection, `"+` accesses the clipboard.

---

## 04.8 - Text objects
<!-- help: 04.8 | :h 04.8 -->

Introduces **operator + text object** pattern:

| Key   | Action                                  | Practice |
|-------|-----------------------------------------|----------|
| `daw` | Delete a word (including whitespace)    | ✓ |
| `diw` | Delete inner word (word only)           | ✓ |
| `cis` | Change inner sentence                   | ✓ |
| `das` | Delete a sentence (including whitespace)| ✓ |

Notes: Text objects work from anywhere inside the object, unlike motions.
Pattern: `{operator}{a/i}{object}` where `a` = "a" (includes surrounding), `i` = "inner".

---

## 04.9 - Replace mode
<!-- help: 04.9 | :h 04.9 -->

| Key | Action                                | Practice |
|-----|---------------------------------------|----------|
| `R` | Enter Replace mode (overtype)         | ✓ |

Notes: Each character typed replaces the one under cursor. `<BS>` restores original.

---

## 04.10 - Conclusion
<!-- help: 04.10 | :h 04.10 -->

Additional commands mentioned:

| Key | Action                                       | Practice |
|-----|----------------------------------------------|----------|
| `~` | Toggle case of character under cursor        | ✓ |
| `I` | Insert at first non-blank of line            | ✓ |
| `A` | Append at end of line                        | ✓ |

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

### Clipboard
- `"*yy` / `"*p` - system selection
- `"+y` / `"+p` - system clipboard

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

# Neovim User Manual - Chapter 05 Extraction

Source: `usr_05.txt` - **Set your settings**

> Covers vimrc/init.vim, mappings, packages, plugins, and common options.

---

## 05.1 - The vimrc file
<!-- help: 05.1 | :h 05.1 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:edit $MYVIMRC` | open the user's init.vim/vimrc | ✓ |

---

## 05.2 - Example vimrc contents
<!-- help: 05.2 | :h 05.2 -->

Settings taught:
- `filetype plugin indent on` — enable filetype detection, plugins, and indent files
- `:set backup` — keep backup copies of files when overwriting
- `:set history=50` — keep 50 commands in history

---

## 05.3 - Simple mappings
<!-- help: 05.3 | :h 05.3 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:map {lhs} {rhs}` | create a mapping | ✗ |
| `:map` | list current mappings | ✓ |

---

## 05.4 - Adding a package
<!-- help: 05.4 | :h 05.4 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:packadd {name}` | enable an optional package | ✓ |

---

## 05.5 - Adding a plugin
<!-- help: 05.5 | :h 05.5 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:filetype plugin on` | enable filetype plugins | ✗ |

---

## 05.6 - Adding a help file
<!-- help: 05.6 | :h 05.6 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:helptags {dir}` | generate tags for local help files | ✓ |
| `:help local-additions` | view locally installed help entries | ✓ |

---

## 05.7 - The option window
<!-- help: 05.7 | :h 05.7 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:options` | open the interactive option window | ✓ |

---

## 05.8 - Often used options
<!-- help: 05.8 | :h 05.8 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:set nowrap` | disable line wrapping | ✗ |
| `:set sidescroll=10` | horizontal scroll context | ✗ |
| `:set whichwrap=b,s,<,>,[,]` | allow keys to wrap across lines | ✗ |
| `:set list` | display tabs and end-of-line markers | ✗ |
| `:set listchars=tab:>-,trail:-` | configure list display characters | ✗ |
| `:set iskeyword` | show/modify keyword characters | ✗ |
| `:set cmdheight=3` | set command-line area height | ✗ |

---

## Summary for Chapter 05

Primarily configuration. No trackable normal-mode keybindings for exercises.

### Commands
- `:edit $MYVIMRC` - open config
- `:options` - interactive option window
- `:packadd` - load optional package
- `:helptags` - generate help tags
- `:map` / `:map {lhs} {rhs}` - mappings

---
---

# Neovim User Manual - Chapter 06 Extraction

Source: `usr_06.txt` - **Using syntax highlighting**

---

## 06.2 - No or wrong colors?
<!-- help: 06.2 | :h 06.2 -->

| Key      | Action                                  | Practice |
|----------|-----------------------------------------|----------|
| `CTRL-L` | Redraw the screen                      | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:set filetype` | check detected filetype | ✗ |
| `:set filetype=fortran` | manually set filetype | ✗ |
| `:set background=dark` / `:set background=light` | tell Vim about terminal background | ✗ |
| `:syntax reset` | reset syntax colors to defaults | ✓ |

---

## 06.3 - Different colors
<!-- help: 06.3 | :h 06.3 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:colorscheme {name}` | apply a named color scheme | ✓ |
| `:highlight {group} ctermfg={color}` | change highlight color for a syntax group | ✗ |

---

## 06.4 - With colors or without colors
<!-- help: 06.4 | :h 06.4 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:syntax on` / `:syntax off` | enable/disable syntax highlighting | ✓ |
| `:syntax clear` | temporarily clear syntax highlighting | ✓ |
| `:syntax manual` | manual syntax mode (per-buffer `:set syntax=ON`) | ✓ |

---

## Summary for Chapter 06

### Keybindings
- `CTRL-L` - redraw screen

### Commands
- `:colorscheme {name}` - apply color scheme
- `:syntax on` / `:syntax off` - toggle syntax highlighting
- `:highlight` - change highlight colors

---
---

# Neovim User Manual - Chapter 07 Extraction

Source: `usr_07.txt` - **Editing more than one file**

---

## 07.1 - Edit another file
<!-- help: 07.1 | :h 07.1 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:edit {file}` | open a file for editing | ✓ |
| `:edit! {file}` | force-open file, discarding unsaved changes | ✓ |
| `:write` | write (save) the current file | ✓ |
| `:hide edit {file}` | switch to another file, hiding the current buffer | ✓ |

---

## 07.2 - A list of files
<!-- help: 07.2 | :h 07.2 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:next` | move to the next file in the argument list | ✓ |
| `:next!` | force move to next file | ✓ |
| `:wnext` | write current file then move to next | ✓ |
| `:previous` | move to the previous file | ✓ |
| `:wprevious` | write current file then move to previous | ✓ |
| `:last` | move to the last file | ✓ |
| `:first` | move to the first file | ✓ |
| `:args` | show the argument list | ✓ |
| `:args {files}` | redefine the argument list (accepts wildcards) | ✓ |
| `:set autowrite` | automatically write files when switching | ✗ |

---

## 07.3 - Jumping from file to file
<!-- help: 07.3 | :h 07.3 -->

| Key    | Action                                     | Practice |
|--------|--------------------------------------------|----------|
| `CTRL-^` | Jump to alternate (previously edited) file | ✓ |
| `` `" `` | Jump to position where cursor was when left file | ✓ |
| `` `. `` | Jump to position of last change in file    | ✓ |

Global marks (uppercase):
- `m{A-Z}` — set a global (cross-file) mark
- `` `{A-Z} `` / `'{A-Z}` — jump to a global mark (opens the file)

| Command | Action | Practice |
|---------|--------|----------|
| `:marks` | list all marks | ✓ |

---

## 07.4 - Backup files
<!-- help: 07.4 | :h 07.4 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:set backup` | enable backup files | ✗ |
| `:set backupext=.bak` | set backup file extension | ✗ |
| `:set patchmode=.orig` | keep original file on first write | ✗ |

---

## 07.5 - Copy text between files
<!-- help: 07.5 | :h 07.5 -->

Introduces **named registers** (`"a` through `"z`):
- `"{reg}y{motion}` — yank into a named register
- `"{reg}p` — put from a named register
- `"Ay{motion}` — append-yank into register `a` (uppercase = append)

| Command | Action | Practice |
|---------|--------|----------|
| `:write >> {file}` | append buffer text to another file | ✓ |

---

## 07.6 - Viewing a file
<!-- help: 07.6 | :h 07.6 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:set modifiable` / `:set write` | re-enable editing on read-only buffer | ✗ |

---

## 07.7 - Changing the file name
<!-- help: 07.7 | :h 07.7 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:saveas {file}` | write buffer under a new name and continue editing it | ✓ |
| `:file {name}` | rename the current buffer (does not write) | ✓ |

---

## Summary for Chapter 07

### Keybindings
- `CTRL-^` - alternate file
- `` `" `` / `` `. `` - predefined marks
- `m{A-Z}` / `` `{A-Z} `` - global marks
- Named register syntax: `"{reg}y`, `"{reg}p`

### Commands
- `:edit` / `:write` / `:hide edit` - file operations
- `:next` / `:previous` / `:first` / `:last` / `:wnext` - argument list
- `:args` - show/redefine argument list
- `:saveas` / `:file` - rename/save-as
- `:write >> {file}` - append to file
- `:marks` - list marks
- `:set autowrite` - auto-save on switch

---
---

# Neovim User Manual - Chapter 08 Extraction

Source: `usr_08.txt` - **Splitting windows**

---

## 08.1 - Split a window
<!-- help: 08.1 | :h 08.1 -->

| Key        | Action                               | Practice |
|------------|--------------------------------------|----------|
| `CTRL-W w` | Move to next window (cycle)          | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:split` | split window horizontally (same file) | ✓ |
| `:close` | close the current window | ✓ |
| `:only` | close all windows except the current one | ✓ |

---

## 08.2 - Split a window on another file
<!-- help: 08.2 | :h 08.2 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:split {file}` | split horizontally and open another file | ✓ |
| `:new` | split horizontally and open a new empty buffer | ✓ |

---

## 08.3 - Window size
<!-- help: 08.3 | :h 08.3 -->

| Key        | Action                               | Practice |
|------------|--------------------------------------|----------|
| `CTRL-W +` | Increase window height               | ✓ |
| `CTRL-W -` | Decrease window height               | ✓ |
| `CTRL-W _` | Maximize window height               | ✓ |
| `CTRL-W =` | Make all windows equal size          | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:{N}split {file}` | split to a window of specific height | ✓ |

---

## 08.4 - Vertical splits
<!-- help: 08.4 | :h 08.4 -->

| Key        | Action                               | Practice |
|------------|--------------------------------------|----------|
| `CTRL-W h` | Move to window on the left           | ✓ |
| `CTRL-W j` | Move to window below                 | ✓ |
| `CTRL-W k` | Move to window above                 | ✓ |
| `CTRL-W l` | Move to window on the right          | ✓ |
| `CTRL-W t` | Move to TOP window                   | ✓ |
| `CTRL-W b` | Move to BOTTOM window                | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:vsplit` / `:vsplit {file}` | vertical split | ✓ |
| `:vnew` | vertical split with new empty buffer | ✓ |
| `:vertical {cmd}` | modifier to force vertical split | ✓ |

---

## 08.5 - Moving windows
<!-- help: 08.5 | :h 08.5 -->

| Key        | Action                               | Practice |
|------------|--------------------------------------|----------|
| `CTRL-W K` | Move window to top (full width)      | ✓ |
| `CTRL-W J` | Move window to bottom (full width)   | ✓ |
| `CTRL-W H` | Move window to far left (full height)| ✓ |
| `CTRL-W L` | Move window to far right (full height)| ✓ |

---

## 08.6 - Commands for all windows
<!-- help: 08.6 | :h 08.6 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:qall` | quit all windows (fails if unsaved) | ✓ |
| `:qall!` | quit all, discarding changes | ✓ |
| `:wall` | write all modified buffers | ✓ |
| `:wqall` | write all and quit | ✓ |
| `:all` | open a window for each file in the argument list | ✓ |
| `:vertical all` | same but with vertical splits | ✓ |

---

## 08.7 - Viewing differences with diff mode
<!-- help: 08.7 | :h 08.7 -->

| Key  | Action                                  | Practice |
|------|-----------------------------------------|----------|
| `]c` | Jump to next change (in diff mode)      | ✓ |
| `[c` | Jump to previous change (in diff mode)  | ✓ |
| `dp` | Diff put — push change to other window  | ✓ |
| `do` | Diff obtain — pull change from other window | ✓ |
| `zo` | Open (unfold) a fold                    | ✓ |
| `zc` | Close a fold                            | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:vertical diffsplit {file}` | open a diff split against another file | ✓ |
| `:vertical diffpatch {file}` | open a diff split applying a patch | ✓ |
| `:diffupdate` | refresh/recalculate diff highlighting | ✓ |

---

## 08.8 - Various
<!-- help: 08.8 | :h 08.8 -->

| Key           | Action                               | Practice |
|---------------|--------------------------------------|----------|
| `CTRL-W CTRL-^` | Split window and edit the alternate file | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:set splitbelow` | new horizontal splits appear below | ✗ |
| `:set splitright` | new vertical splits appear to the right | ✗ |
| `:leftabove {cmd}` / `:aboveleft {cmd}` | split left of or above | ✗ |
| `:rightbelow {cmd}` / `:belowright {cmd}` | split right of or below | ✗ |
| `:topleft {cmd}` | split at the top or far left | ✗ |
| `:botright {cmd}` | split at the bottom or far right | ✗ |

---

## 08.9 - Tab pages
<!-- help: 08.9 | :h 08.9 -->

| Key  | Action                                  | Practice |
|------|-----------------------------------------|----------|
| `gt` | Go to next tab page                     | ✓ |
| `gT` | Go to previous tab page                 | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:tabedit {file}` | open a file in a new tab page | ✓ |
| `:tab split` | duplicate current window into a new tab | ✓ |
| `:tab {cmd}` | modifier to open in a new tab | ✓ |
| `:tabonly` | close all tab pages except current | ✓ |

---

## Summary for Chapter 08

### Keybindings
- `CTRL-W w/h/j/k/l/t/b` - window navigation
- `CTRL-W K/J/H/L` - window moving
- `CTRL-W +/-/_/=` - window sizing
- `CTRL-W CTRL-^` - split alternate file
- `]c` / `[c` / `dp` / `do` - diff navigation
- `zo` / `zc` - fold open/close
- `gt` / `gT` - tab navigation

### Commands
- `:split` / `:vsplit` / `:new` / `:vnew` - split windows
- `:close` / `:only` - close windows
- `:qall` / `:wall` / `:wqall` - all-window operations
- `:tabedit` / `:tabonly` - tab operations
- `:vertical diffsplit` / `:diffupdate` - diff mode

---
---

# Neovim User Manual - Chapter 09 Extraction

Source: `usr_09.txt` - **Using the GUI**

> GUI-specific chapter. Most content is GUI-only (menus, mouse, scrollbars).

---

## 09.3 - The clipboard
<!-- help: 09.3 | :h 09.3 -->

Register usage (extending 04.7):
- `"*` register — system selection (X11 primary)
- `"+` register — system clipboard (X11 clipboard)

---

## Summary for Chapter 09

Primarily GUI-specific. No new trackable normal-mode keybindings for exercises beyond clipboard registers already covered in 04.7.

---
---

# Neovim User Manual - Chapter 10 Extraction

Source: `usr_10.txt` - **Making big changes**

---

## 10.1 - Record and playback commands
<!-- help: 10.1 | :h 10.1 -->

| Key              | Action                                    | Practice |
|------------------|-------------------------------------------|----------|
| `q{a-z}`         | Start recording keystrokes into register  | ✓ |
| `q`              | Stop recording                            | ✓ |
| `@{a-z}`         | Execute/replay macro from register        | ✓ |
| `@@`             | Re-execute the last played register       | ✓ |
| `{count}@{a-z}`  | Execute macro count times                 | ✓ |

Notes: Uppercase register (`qA`) appends to existing macro.

---

## 10.2 - Substitution
<!-- help: 10.2 | :h 10.2 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:[range]s/{from}/{to}/[flags]` | substitute | ✓ |
| `:%s/old/new/g` | replace all occurrences in whole file | ✓ |
| `:%s/old/new/gc` | replace with confirmation | ✓ |
| `:%s/old/new/ge` | suppress "not found" error | ✓ |
| `:s/old/new/` | substitute on current line only | ✓ |

Confirm-mode responses (during `:%s/.../c`):
- `y` yes, `n` skip, `a` all, `q` quit, `l` last

Notes: Alternate separators work: `:s+one/two+one or two+`

---

## 10.3 - Command ranges
<!-- help: 10.3 | :h 10.3 -->

Range syntax:
- `:1,5s/this/that/g` — lines 1 to 5
- `:%s/.../.../` — `%` = whole file (shorthand for `1,$`)
- `:.,$s/yes/no/` — current line to end of file
- `:'t,'b` — range using marks
- `:'<,'>` — range of last Visual selection
- `?pattern?,/pattern/` — pattern-based range
- `/pattern/+2` — offsets on range endpoints

---

## 10.4 - The global command
<!-- help: 10.4 | :h 10.4 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:[range]g/{pattern}/{command}` | execute command on all matching lines | ✓ |
| `:g!/{pattern}/{command}` | execute on non-matching lines (also `:v/...`) | ✓ |

---

## 10.5 - Visual block mode
<!-- help: 10.5 | :h 10.5 -->

| Key       | Context      | Action                                | Practice |
|-----------|--------------|---------------------------------------|----------|
| `I{str}<Esc>` | Visual block | Insert text before block on every line | ✓ |
| `A{str}<Esc>` | Visual block | Append text after block on every line | ✓ |
| `c{str}<Esc>` | Visual block | Delete block and insert replacement   | ✓ |
| `C{str}<Esc>` | Visual block | Delete to EOL and insert on every line | ✓ |
| `r{char}` | Visual block | Replace all chars in block            | ✓ |
| `~`       | Visual       | Swap case of selection                | ✓ |
| `U`       | Visual       | Make selection uppercase              | ✓ |
| `u`       | Visual       | Make selection lowercase              | ✓ |
| `>`       | Visual       | Shift selection right                 | ✓ |
| `<`       | Visual       | Shift selection left                  | ✓ |
| `J`       | Visual       | Join selected lines (normalize space) | ✓ |
| `gJ`      | Visual       | Join selected lines (preserve space)  | ✓ |

---

## 10.6 - Reading and writing part of a file
<!-- help: 10.6 | :h 10.6 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:read {file}` | insert file contents below cursor line | ✓ |
| `:0read {file}` | insert file above first line | ✓ |
| `:{range}write {file}` | write range of lines to file | ✓ |
| `:write >> {file}` | append to file | ✓ |
| `:read !{cmd}` | insert output of shell command into buffer | ✓ |
| `:write !{cmd}` | send buffer contents to shell command as stdin | ✓ |

---

## 10.7 - Formatting text
<!-- help: 10.7 | :h 10.7 -->

| Key     | Action                                     | Practice |
|---------|--------------------------------------------|----------|
| `gqap`  | Format current paragraph                   | ✓ |
| `gq{motion}` | Format operator (with any motion)     | ✓ |
| `gggqG` | Format entire file                         | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:set textwidth=78` | auto-wrap lines at 78 characters | ✗ |

---

## 10.8 - Changing case
<!-- help: 10.8 | :h 10.8 -->

| Key       | Action                                  | Practice |
|-----------|-----------------------------------------|----------|
| `gU{motion}` | Make text uppercase                  | ✓ |
| `gu{motion}` | Make text lowercase                  | ✓ |
| `g~{motion}` | Swap case of text                    | ✓ |
| `gUU`     | Make entire line uppercase              | ✓ |
| `guu`     | Make entire line lowercase              | ✓ |
| `g~~`     | Swap case of entire line                | ✓ |
| `gUw`     | Make word uppercase                     | ✓ |
| `guw`     | Make word lowercase                     | ✓ |

---

## 10.9 - Using an external program
<!-- help: 10.9 | :h 10.9 -->

| Key             | Action                                  | Practice |
|-----------------|-----------------------------------------|----------|
| `!{motion}{prog}` | Filter text through external program  | ✓ |
| `!!{prog}`      | Filter current line through program     | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:!{command}` | execute external command | ✓ |
| `:{range}!{command}` | filter range through external command | ✓ |

---

## Summary for Chapter 10

### Keybindings
- `q{a-z}` / `q` / `@{a-z}` / `@@` - macro record/playback
- `gq{motion}` - format text
- `gU{motion}` / `gu{motion}` / `g~{motion}` - change case
- `!{motion}{prog}` / `!!{prog}` - external filter
- Visual block: `I`, `A`, `c`, `C`, `r`, `~`, `U`, `u`, `>`, `<`, `J`, `gJ`

### Commands
- `:[range]s/{from}/{to}/[flags]` - substitute
- `:[range]g/{pattern}/{command}` - global command
- `:read {file}` / `:read !{cmd}` - read file/command output
- `:{range}write {file}` - write range to file
- `:!{command}` / `:{range}!{command}` - external commands
- `:set textwidth` - line wrap width

---
---

# Neovim User Manual - Chapter 11 Extraction

Source: `usr_11.txt` - **Recovering from a crash**

---

## 11.1 - Basic recovery
<!-- help: 11.1 | :h 11.1 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:recover` | manually recover from swap file | ✓ |
| `:write {file}` | save recovered buffer under a new name | ✓ |
| `:edit #` | re-open the previous (original) file | ✓ |
| `:diffsp {file}` | open a diff split against the original file | ✓ |

---

## Summary for Chapter 11

Primarily conceptual (swap file mechanics). No trackable keybindings for exercises.

### Commands
- `:recover` - recover from swap file
- `:diffsp` - diff against original

---
---

# Neovim User Manual - Chapter 12 Extraction

Source: `usr_12.txt` - **Clever tricks**

---

## 12.1 - Replace a word
<!-- help: 12.1 | :h 12.1 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:%s/\<old\>/new/g` | whole-word replace | ✓ |
| `:%s/\<old\>/new/gc` | whole-word replace with confirmation | ✓ |
| `:%s/\<old\>/new/ge` | suppress "not found" error | ✓ |

---

## 12.2 - Change "Last, First" to "First Last"
<!-- help: 12.2 | :h 12.2 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:%s/\([^,]*\), \(.*\)/\2 \1/` | swap using backreferences (`\1`, `\2`) | ✓ |

---

## 12.3 - Sort a list
<!-- help: 12.3 | :h 12.3 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:{range}!sort` | filter lines through external `sort` | ✓ |

---

## 12.4 - Reverse line order
<!-- help: 12.4 | :h 12.4 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:g/^/m 0` | reverse all lines in file (move each to position 0) | ✓ |

---

## 12.5 - Count words
<!-- help: 12.5 | :h 12.5 -->

| Key         | Action                                  | Practice |
|-------------|-----------------------------------------|----------|
| `g CTRL-G`  | Show word, line, character, byte counts | ✓ |

Notes: In Visual mode, counts only the selection.

---

## 12.6 - Find a man page
<!-- help: 12.6 | :h 12.6 -->

| Key | Action                                | Practice |
|-----|---------------------------------------|----------|
| `K` | Look up man page for word under cursor | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:Man {topic}` | open man page in a split window | ✓ |
| `:Man {section} {topic}` | open man page from specific section | ✓ |

---

## 12.7 - Trim blanks
<!-- help: 12.7 | :h 12.7 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:%s/\s\+$//` | remove trailing whitespace from every line | ✓ |

---

## 12.8 - Find where a word is used
<!-- help: 12.8 | :h 12.8 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:grep {pattern} {files}` | search across files, populate quickfix | ✓ |
| `:cnext` | jump to next quickfix match | ✓ |
| `:cprev` | jump to previous quickfix match | ✓ |
| `:clist` | list all quickfix matches | ✓ |

---

## Summary for Chapter 12

### Keybindings
- `g CTRL-G` - word/line/byte count
- `K` - man page lookup

### Commands
- `:%s/\<old\>/new/g` - whole-word replace
- `:%s/\([^,]*\), \(.*\)/\2 \1/` - backreference swap
- `:g/^/m 0` - reverse lines
- `:%s/\s\+$//` - trim trailing whitespace
- `:grep` / `:cnext` / `:cprev` / `:clist` - cross-file search

---
---

# Neovim User Manual - Chapter 20 Extraction

Source: `usr_20.txt` - **Typing command-line commands quickly**

---

## 20.1 - Command line editing
<!-- help: 20.1 | :h 20.1 -->

Command-line mode keybindings:

| Key      | Action                                | Practice |
|----------|---------------------------------------|----------|
| `<Left>` / `<Right>` | Move one character left/right | ✓ |
| `<S-Left>` / `<S-Right>` | Move one word left/right | ✓ |
| `CTRL-B` / `<Home>` | Move to beginning of command line | ✓ |
| `CTRL-E` / `<End>` | Move to end of command line | ✓ |
| `CTRL-W` | Delete word before cursor             | ✓ |
| `CTRL-U` | Remove all text on command line        | ✓ |

---

## 20.3 - Command line completion
<!-- help: 20.3 | :h 20.3 -->

Command-line mode keybindings:

| Key      | Action                                | Practice |
|----------|---------------------------------------|----------|
| `<Tab>`  | Complete word (cycle forward)          | ✓ |
| `CTRL-D` | List all completion matches            | ✓ |
| `CTRL-L` | Complete to longest unambiguous string | ✓ |
| `CTRL-P` | Cycle backward through matches         | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:set wildmenu` | enable menu-style completion | ✗ |
| `:set wildmode=...` | change completion behavior | ✗ |

---

## 20.4 - Command line history
<!-- help: 20.4 | :h 20.4 -->

Command-line mode keybindings:

| Key      | Action                                | Practice |
|----------|---------------------------------------|----------|
| `<Up>` / `<Down>` | Recall older/newer command (filters by prefix) | ✓ |
| `CTRL-P` / `CTRL-N` | Previous/next history (no filter) | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:history` | show command history | ✓ |
| `:history /` | show search history | ✓ |

---

## 20.5 - Command line window
<!-- help: 20.5 | :h 20.5 -->

| Key  | Action                                    | Practice |
|------|-------------------------------------------|----------|
| `q:` | Open the command-line window (`:` history) | ✓ |
| `q/` | Open the search history window             | ✓ |

---

## Summary for Chapter 20

### Keybindings
- `q:` / `q/` - command-line/search history window
- Command-line mode: `Tab`, `Ctrl-D`, `Ctrl-L`, `Ctrl-W`, `Ctrl-U`, `Ctrl-P/N`

### Commands
- `:history` / `:history /` - show history
- `:set wildmenu` - completion menu

---
---

# Neovim User Manual - Chapter 21 Extraction

Source: `usr_21.txt` - **Go away and come back**

---

## 21.1 - Suspend and resume
<!-- help: 21.1 | :h 21.1 -->

| Key      | Action                                | Practice |
|----------|---------------------------------------|----------|
| `CTRL-Z` | Suspend Vim (Unix only)               | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:suspend` | suspend Vim (alternative to CTRL-Z) | ✓ |

---

## 21.2 - Executing shell commands
<!-- help: 21.2 | :h 21.2 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:!{program}` | execute an external program | ✓ |
| `:read !{program}` | read output into buffer | ✓ |
| `:write !{program}` | send buffer to program stdin | ✓ |
| `:{range}!{program}` | filter range through program | ✓ |
| `:terminal` | start a shell in a terminal buffer | ✓ |

---

## 21.3 - Remembering information; ShaDa
<!-- help: 21.3 | :h 21.3 -->

| Key   | Action                                 | Practice |
|-------|----------------------------------------|----------|
| `'0`  | Jump to position where last exited Vim | ✓ |
| `'1`-`'9` | Jump to older exit positions      | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:oldfiles` | list recently edited files | ✓ |
| `:browse oldfiles` | interactively browse recent files | ✓ |
| `:edit #<{N}` | edit Nth file from `:oldfiles` | ✓ |
| `:wshada` / `:rshada` | write/read ShaDa info | ✓ |

---

## 21.4 - Sessions
<!-- help: 21.4 | :h 21.4 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:mksession {file}` | save current editing session | ✓ |
| `:mksession! {file}` | overwrite existing session file | ✓ |
| `:source {file}` | load/restore a session (or any Vim script) | ✓ |

---

## 21.5 - Views
<!-- help: 21.5 | :h 21.5 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:mkview` | save a view for the current window | ✓ |
| `:mkview {N}` | save numbered view (1-9) | ✓ |
| `:loadview` | restore saved view | ✓ |
| `:loadview {N}` | restore numbered view | ✓ |

---

## Summary for Chapter 21

### Keybindings
- `CTRL-Z` - suspend Vim
- `'0` through `'9` - ShaDa exit marks

### Commands
- `:terminal` - terminal buffer
- `:mksession` / `:source` - sessions
- `:mkview` / `:loadview` - views
- `:oldfiles` / `:browse oldfiles` - recent files

---
---

# Neovim User Manual - Chapter 22 Extraction

Source: `usr_22.txt` - **Finding the file to edit**

---

## 22.1 - The file browser (netrw)
<!-- help: 22.1 | :h 22.1 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:edit .` | open file browser for current directory | ✓ |
| `:Explore` / `:Explore {dir}` | browse a directory | ✓ |

Netrw normal-mode keys:

| Key   | Action                                  | Practice |
|-------|-----------------------------------------|----------|
| `<CR>` | Open file / enter directory            | ✓ |
| `o`   | Open file in horizontal split           | ✓ |
| `v`   | Open file in vertical split             | ✓ |
| `p`   | Open file in preview window             | ✓ |
| `t`   | Open file in a new tab                  | ✓ |
| `-`   | Go up one directory level               | ✓ |
| `i`   | Cycle listing style (thin/long/wide/tree) | ✓ |
| `s`   | Cycle sort order (name/time/size)       | ✓ |
| `r`   | Reverse sort order                      | ✓ |
| `R`   | Rename file/directory under cursor      | ✓ |
| `D`   | Delete file/directory under cursor      | ✓ |

---

## 22.2 - The current directory
<!-- help: 22.2 | :h 22.2 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:cd {dir}` | change current directory | ✓ |
| `:cd -` | switch back to previous directory | ✓ |
| `:pwd` | print current working directory | ✓ |
| `:lcd {dir}` | change directory for current window only | ✓ |
| `:tcd {dir}` | change directory for current tab only | ✓ |

---

## 22.3 - Finding a file
<!-- help: 22.3 | :h 22.3 -->

| Key        | Action                                    | Practice |
|------------|-------------------------------------------|----------|
| `gf`       | Go to file whose name is under the cursor | ✓ |
| `CTRL-W f` | Open file under cursor in a new split     | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:find {file}` | find and edit a file using the `'path'` option | ✓ |
| `:sfind {file}` | find and open in a split | ✓ |
| `:set path+={dir}` | add directory to file search path | ✗ |

---

## 22.4 - The buffer list
<!-- help: 22.4 | :h 22.4 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:buffers` / `:ls` | list all buffers | ✓ |
| `:buffer {N}` | edit buffer by number | ✓ |
| `:buffer {name}` | edit buffer by (partial) name | ✓ |
| `:sbuffer {N}` | open buffer in a new split | ✓ |
| `:bnext` / `:bprevious` | next/previous buffer | ✓ |
| `:bfirst` / `:blast` | first/last buffer | ✓ |
| `:bdelete {N}` | remove buffer from list | ✓ |
| `:bwipe` | completely remove buffer from memory | ✓ |

---

## Summary for Chapter 22

### Keybindings
- `gf` - go to file under cursor
- `CTRL-W f` - go to file in split
- Netrw keys: `<CR>`, `o`, `v`, `p`, `t`, `-`, `i`, `s`, `r`, `R`, `D`

### Commands
- `:Explore` / `:edit .` - file browser
- `:cd` / `:lcd` / `:tcd` / `:pwd` - directory management
- `:find` / `:sfind` - find files in path
- `:buffers` / `:bnext` / `:bprevious` / `:bdelete` - buffer management

---
---

# Neovim User Manual - Chapter 23 Extraction

Source: `usr_23.txt` - **Editing other files**

---

## 23.1 - DOS, Mac and Unix files
<!-- help: 23.1 | :h 23.1 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:set fileformat=unix` | set file format (for conversion on write) | ✗ |
| `:set fileformats=unix,dos` | set detection order | ✗ |
| `:edit ++ff=unix {file}` | force file format for this edit | ✓ |
| `:edit ++enc={encoding} {file}` | force encoding for this edit | ✓ |

---

## 23.3 - Binary files
<!-- help: 23.3 | :h 23.3 -->

| Key    | Action                                  | Practice |
|--------|-----------------------------------------|----------|
| `ga`   | Show decimal/hex/octal value of char    | ✓ |
| `{N}go` | Go to byte number N in the file        | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:%!xxd` | convert buffer to hex dump | ✓ |
| `:%!xxd -r` | convert hex dump back to binary | ✓ |
| `:set display=uhex` | display unprintable chars in hex | ✗ |

---

## Summary for Chapter 23

### Keybindings
- `ga` - show character value
- `{N}go` - go to byte N

### Commands
- `:set fileformat` / `:set fileformats` - file format handling
- `:edit ++ff=` / `:edit ++enc=` - force format/encoding
- `:%!xxd` / `:%!xxd -r` - hex editing

---
---

# Neovim User Manual - Chapter 24 Extraction

Source: `usr_24.txt` - **Inserting quickly**

---

## 24.1 - Making corrections
<!-- help: 24.1 | :h 24.1 -->

Insert-mode keybindings:

| Key      | Action                                | Practice |
|----------|---------------------------------------|----------|
| `CTRL-W` | Delete word before cursor             | ✓ |
| `CTRL-U` | Delete from first non-blank to cursor | ✓ |

---

## 24.3 - Completion
<!-- help: 24.3 | :h 24.3 -->

Insert-mode keybindings:

| Key            | Action                                | Practice |
|----------------|---------------------------------------|----------|
| `CTRL-P`       | Complete word backward                | ✓ |
| `CTRL-N`       | Complete word forward                 | ✓ |
| `CTRL-X CTRL-F` | Complete file names                 | ✓ |
| `CTRL-X CTRL-L` | Complete whole lines                | ✓ |
| `CTRL-X CTRL-D` | Complete macro definitions          | ✓ |
| `CTRL-X CTRL-I` | Complete from included files        | ✓ |
| `CTRL-X CTRL-K` | Complete from dictionary            | ✓ |
| `CTRL-X CTRL-T` | Complete from thesaurus             | ✓ |
| `CTRL-X CTRL-]` | Complete tag names                  | ✓ |
| `CTRL-X CTRL-V` | Complete Vim command-line syntax    | ✓ |
| `CTRL-X CTRL-O` | Omni completion (context-aware)     | ✓ |

---

## 24.4 - Repeating an insert
<!-- help: 24.4 | :h 24.4 -->

Insert-mode keybindings:

| Key      | Action                                | Practice |
|----------|---------------------------------------|----------|
| `CTRL-A` | Insert text typed in last Insert session | ✓ |
| `CTRL-@` | Insert last text and exit Insert mode | ✓ |

---

## 24.5 - Copying from another line
<!-- help: 24.5 | :h 24.5 -->

Insert-mode keybindings:

| Key      | Action                                | Practice |
|----------|---------------------------------------|----------|
| `CTRL-Y` | Insert character from line above      | ✓ |
| `CTRL-E` | Insert character from line below      | ✓ |

---

## 24.6 - Inserting a register
<!-- help: 24.6 | :h 24.6 -->

Insert-mode keybindings:

| Key                    | Action                                | Practice |
|------------------------|---------------------------------------|----------|
| `CTRL-R {register}`    | Insert contents of register           | ✓ |
| `CTRL-R CTRL-R {register}` | Insert register literally        | ✓ |

---

## 24.7 - Abbreviations
<!-- help: 24.7 | :h 24.7 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:iabbrev {abbr} {expansion}` | define insert-mode abbreviation | ✗ |
| `:abbreviate` | list all abbreviations | ✓ |
| `:unabbreviate {abbr}` | remove an abbreviation | ✓ |
| `:abclear` | remove all abbreviations | ✓ |

---

## 24.8 - Entering special characters
<!-- help: 24.8 | :h 24.8 -->

Insert-mode keybindings:

| Key              | Action                                | Practice |
|------------------|---------------------------------------|----------|
| `CTRL-V {char}`  | Insert next character literally        | ✓ |
| `CTRL-V {digits}` | Insert character by decimal number   | ✓ |
| `CTRL-V u{hex}`  | Insert Unicode character (16-bit)     | ✓ |
| `CTRL-V U{hex}`  | Insert Unicode character (32-bit)     | ✓ |

---

## 24.9 - Digraphs
<!-- help: 24.9 | :h 24.9 -->

Insert-mode keybindings:

| Key                | Action                                | Practice |
|--------------------|---------------------------------------|----------|
| `CTRL-K {two chars}` | Insert a digraph (special character) | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:digraphs` | display the full digraph table | ✓ |
| `:digraph {chars} {number}` | define a custom digraph | ✗ |

---

## 24.10 - Normal mode commands from Insert mode
<!-- help: 24.10 | :h 24.10 -->

Insert-mode keybindings:

| Key             | Action                                | Practice |
|-----------------|---------------------------------------|----------|
| `CTRL-O {cmd}`  | Execute one Normal mode command without leaving Insert mode | ✓ |

---

## Summary for Chapter 24

### Insert-mode keybindings
- `CTRL-P` / `CTRL-N` - word completion
- `CTRL-X CTRL-F/L/D/I/K/T/]/V/O` - specific completions
- `CTRL-A` / `CTRL-@` - repeat last insert
- `CTRL-Y` / `CTRL-E` - copy from above/below line
- `CTRL-R {reg}` - insert register contents
- `CTRL-V {char}` - literal insert
- `CTRL-K {chars}` - digraph insert
- `CTRL-O {cmd}` - execute one Normal command
- `CTRL-W` / `CTRL-U` - delete word/line

### Commands
- `:iabbrev` / `:abbreviate` / `:unabbreviate` / `:abclear` - abbreviations
- `:digraphs` / `:digraph` - digraphs

---
---

# Neovim User Manual - Chapter 25 Extraction

Source: `usr_25.txt` - **Editing formatted text**

---

## 25.1 - Breaking lines
<!-- help: 25.1 | :h 25.1 -->

| Key     | Action                                     | Practice |
|---------|--------------------------------------------|----------|
| `gq{motion}` | Format operator (reformat text to textwidth) | ✓ |
| `gqap`  | Format current paragraph                   | ✓ |
| `gggqG` | Format entire file                         | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:set textwidth=78` | auto-wrap at 78 chars | ✗ |
| `:set wrap` / `:set nowrap` | enable/disable visual line wrapping | ✗ |

---

## 25.2 - Aligning text
<!-- help: 25.2 | :h 25.2 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:{range}center [width]` | center lines | ✓ |
| `:{range}right [width]` | right-justify lines | ✓ |
| `:{range}left [margin]` | left-align lines with optional indent | ✓ |

---

## 25.3 - Indents and Tabs
<!-- help: 25.3 | :h 25.3 -->

| Key  | Action                                | Practice |
|------|---------------------------------------|----------|
| `>>` | Increase indent of current line       | ✓ |
| `<<` | Decrease indent of current line       | ✓ |
| `>`  | Indent operator (with motion/object)  | ✓ |
| `<`  | Unindent operator (with motion/object)| ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:set autoindent` | auto-indent new lines | ✗ |
| `:set shiftwidth=4` | set indent width | ✗ |
| `:set softtabstop=4` | Tab key inserts 4 spaces of indent | ✗ |
| `:set expandtab` | use spaces instead of tabs | ✗ |
| `:set tabstop=N` | set tab display width | ✗ |
| `:retab` | convert indentation to current settings | ✓ |

---

## 25.4 - Dealing with long lines
<!-- help: 25.4 | :h 25.4 -->

Horizontal scrolling:

| Key  | Action                                | Practice |
|------|---------------------------------------|----------|
| `zh` | Scroll right (one character)          | ✓ |
| `zl` | Scroll left (one character)           | ✓ |
| `zH` | Scroll right half a window width      | ✓ |
| `zL` | Scroll left half a window width       | ✓ |
| `zs` | Scroll to put cursor at screen start  | ✓ |
| `ze` | Scroll to put cursor at screen end    | ✓ |

Visible-line movement:

| Key  | Action                                | Practice |
|------|---------------------------------------|----------|
| `g0` | First visible character in screen line | ✓ |
| `g^` | First non-blank visible char in screen line | ✓ |
| `gm` | Middle of screen line                 | ✓ |
| `g$` | Last visible character in screen line | ✓ |
| `gj` | Move down one screen line             | ✓ |
| `gk` | Move up one screen line               | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:set linebreak` | break display at word boundaries | ✗ |

---

## 25.5 - Editing tables
<!-- help: 25.5 | :h 25.5 -->

| Key   | Action                                | Practice |
|-------|---------------------------------------|----------|
| `gr{char}` | Virtual replace single character (preserves layout) | ✓ |
| `gR`  | Enter Virtual Replace mode             | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:set virtualedit=all` | cursor can move beyond end of line | ✗ |

---

## Summary for Chapter 25

### Keybindings
- `gq{motion}` - format text
- `>>` / `<<` / `>` / `<` - indent/unindent
- `zh` / `zl` / `zH` / `zL` / `zs` / `ze` - horizontal scrolling
- `g0` / `g^` / `gm` / `g$` / `gj` / `gk` - screen line movement
- `gr{char}` / `gR` - virtual replace

### Commands
- `:center` / `:right` / `:left` - text alignment
- `:set textwidth` / `:set linebreak` - line wrapping
- `:set autoindent` / `:set shiftwidth` / `:set expandtab` - indentation
- `:set virtualedit=all` - virtual editing
- `:retab` - convert indentation

---
---

# Neovim User Manual - Chapter 26 Extraction

Source: `usr_26.txt` - **Repeating**

---

## 26.1 - Repeating with Visual mode
<!-- help: 26.1 | :h 26.1 -->

| Key  | Action                                | Practice |
|------|---------------------------------------|----------|
| `gv` | Reselect the previous Visual selection | ✓ |

---

## 26.2 - Add and subtract
<!-- help: 26.2 | :h 26.2 -->

| Key      | Action                                | Practice |
|----------|---------------------------------------|----------|
| `CTRL-A` | Increment number under cursor         | ✓ |
| `CTRL-X` | Decrement number under cursor         | ✓ |

Notes: Count prefix works: `5 CTRL-A` adds 5. Combine with `n` and `.` for multi-occurrence edits.

---

## 26.3 - Making a change in many files
<!-- help: 26.3 | :h 26.3 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:argdo {cmd}` | execute command on all files in arglist | ✓ |
| `:windo {cmd}` | execute command in all windows | ✓ |
| `:bufdo {cmd}` | execute command on all buffers | ✓ |

Notes: Commonly used with `| update` to save only changed files.

---

## Summary for Chapter 26

### Keybindings
- `gv` - reselect visual
- `CTRL-A` / `CTRL-X` - increment/decrement number

### Commands
- `:argdo` / `:windo` / `:bufdo` - execute across files/windows/buffers

---
---

# Neovim User Manual - Chapter 27 Extraction

Source: `usr_27.txt` - **Search commands and patterns**

---

## 27.1 - Ignoring case
<!-- help: 27.1 | :h 27.1 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:set ignorecase` | case-insensitive searching | ✗ |
| `:set ignorecase smartcase` | case-insensitive unless uppercase in pattern | ✗ |

Search pattern modifiers:
- `\c` — force case-insensitive for this pattern
- `\C` — force case-sensitive for this pattern

---

## 27.3 - Offsets
<!-- help: 27.3 | :h 27.3 -->

Search offset syntax:
- `/pattern/2` — land 2 lines below match
- `/pattern/e` — land at end of match
- `/pattern/e+1` — land 1 char after end
- `/pattern/b+2` — land 2 chars after start

---

## 27.4-27.8 - Pattern syntax (regex reference)
<!-- help: 27.4 | :h 27.4 -->

Key pattern atoms:
- `*` — 0 or more (greedy)
- `\+` — 1 or more
- `\=` — 0 or 1
- `\{n,m}` — n to m times
- `\{-}` — 0 or more (non-greedy)
- `\|` — alternation (or)
- `\(\)` — grouping
- `\<` / `\>` — word boundaries
- `\d` digit, `\s` whitespace, `\a` alpha, `\w` word char
- `\n` — match line break in pattern
- `\_s` — whitespace or line break
- `\_.` — any character or line break

---

## Summary for Chapter 27

### Commands
- `:set ignorecase smartcase` - smart case search

### Pattern reference
- `\c` / `\C` - per-pattern case control
- `/pattern/e` - search with offset
- `\<word\>` - word boundaries
- `\+`, `\=`, `\{n,m}`, `\{-}` - quantifiers
- `\|`, `\(\)` - alternation, grouping
- `\d`, `\s`, `\a`, `\w`, `\_s`, `\_.` - character classes

---
---

# Neovim User Manual - Chapter 28 Extraction

Source: `usr_28.txt` - **Folding**

---

## 28.2 - Manual folding
<!-- help: 28.2 | :h 28.2 -->

| Key  | Action                                | Practice |
|------|---------------------------------------|----------|
| `zf{motion}` | Create a fold                  | ✓ |
| `zfap` | Create fold over a paragraph        | ✓ |
| `zo`  | Open one fold under cursor            | ✓ |
| `zc`  | Close one fold under cursor           | ✓ |
| `zO`  | Open all folds at cursor (recursive)  | ✓ |
| `zC`  | Close all folds at cursor (recursive) | ✓ |
| `zr`  | Reduce folding (open one level)       | ✓ |
| `zm`  | Fold more (close one level)           | ✓ |
| `zR`  | Open all folds                        | ✓ |
| `zM`  | Close all folds                       | ✓ |
| `zn`  | Disable folding entirely              | ✓ |
| `zN`  | Re-enable folding                     | ✓ |
| `zi`  | Toggle folding on/off                 | ✓ |
| `zd`  | Delete fold at cursor                 | ✓ |
| `zD`  | Delete all folds at cursor (recursive)| ✓ |

---

## 28.3-28.4 - Working with folds
<!-- help: 28.3 | :h 28.3 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:set foldmethod=manual` / `indent` / `marker` / `syntax` / `expr` | set fold method | ✗ |
| `:set foldcolumn=4` | show fold indicator column | ✗ |
| `:set foldlevel=N` | set fold depth | ✗ |
| `:mkview` / `:loadview` | save/restore folds | ✓ |

---

## 28.6 - Folding with markers
<!-- help: 28.6 | :h 28.6 -->

Marker syntax in text: `{{{` / `}}}` (with optional level numbers `{{{1}`)

---

## Summary for Chapter 28

### Keybindings
- `zf{motion}` - create fold
- `zo` / `zc` / `zO` / `zC` - open/close folds
- `zr` / `zm` / `zR` / `zM` - fold level control
- `zn` / `zN` / `zi` - toggle folding
- `zd` / `zD` - delete folds

### Commands
- `:set foldmethod=` - fold method
- `:set foldcolumn=` / `:set foldlevel=` - fold display
- `:mkview` / `:loadview` - save/restore folds

---
---

# Neovim User Manual - Chapter 29 Extraction

Source: `usr_29.txt` - **Moving through programs**

---

## 29.1 - Using tags
<!-- help: 29.1 | :h 29.1 -->

| Key        | Action                                    | Practice |
|------------|-------------------------------------------|----------|
| `CTRL-]`   | Jump to tag of word under cursor          | ✓ |
| `CTRL-T`   | Jump back to previous tag                 | ✓ |
| `CTRL-W ]` | Split window and jump to tag              | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:tag {name}` | jump to tag definition | ✓ |
| `:tags` | show tag stack | ✓ |
| `:stag {name}` | split window and jump to tag | ✓ |
| `:tnext` / `:tprevious` / `:tfirst` / `:tlast` | navigate multiple tag matches | ✓ |
| `:tselect {name}` | show list of matching tags to choose from | ✓ |

---

## 29.2 - The preview window
<!-- help: 29.2 | :h 29.2 -->

| Key        | Action                                    | Practice |
|------------|-------------------------------------------|----------|
| `CTRL-W }` | Open preview window for tag under cursor  | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:ptag {name}` | open preview window showing tag definition | ✓ |
| `:pclose` | close preview window | ✓ |
| `:pedit {file}` | edit file in preview window | ✓ |
| `:psearch {word}` | search and show match in preview window | ✓ |

---

## 29.3 - Moving through a program
<!-- help: 29.3 | :h 29.3 -->

| Key  | Action                                  | Practice |
|------|-----------------------------------------|----------|
| `[#` | Jump to unclosed `#if` / `#ifdef`       | ✓ |
| `]#` | Jump to next `#else` / `#endif`         | ✓ |
| `[[` | Move to start of outer `{` block        | ✓ |
| `]]` | Move to start of next function          | ✓ |
| `][` | Move to end of outer `}` block          | ✓ |
| `[]` | Move backward to end of function        | ✓ |
| `[{` | Move to start of current `{}` block     | ✓ |
| `]}` | Move to end of current `{}` block       | ✓ |
| `[(` | Move to unclosed `(` to the left        | ✓ |
| `])` | Move to unclosed `)` to the right       | ✓ |
| `[/` | Move to start of `/* */` comment        | ✓ |
| `]/` | Move to end of `/* */` comment          | ✓ |
| `[m` | Move to previous method start (C++/Java)| ✓ |
| `]m` | Move to next method start (C++/Java)    | ✓ |

---

## 29.4 - Finding global identifiers
<!-- help: 29.4 | :h 29.4 -->

| Key       | Action                                  | Practice |
|-----------|-----------------------------------------|----------|
| `[I`      | List all matches for word under cursor  | ✓ |
| `[i`      | Show first match for word under cursor  | ✓ |
| `]I`      | List matches below cursor               | ✓ |
| `[D`      | List `#define` matches for word         | ✓ |
| `[d`      | Show first `#define` match              | ✓ |
| `[<Tab>`  | Jump to first match from `[I` list      | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:checkpath` | list included files that cannot be found | ✓ |
| `:checkpath!` | list all included files | ✓ |

---

## 29.5 - Finding local identifiers
<!-- help: 29.5 | :h 29.5 -->

| Key  | Action                                  | Practice |
|------|-----------------------------------------|----------|
| `gD` | Jump to global declaration of identifier| ✓ |
| `gd` | Jump to local declaration of identifier | ✓ |

---

## Summary for Chapter 29

### Keybindings
- `CTRL-]` / `CTRL-T` / `CTRL-W ]` / `CTRL-W }` - tag navigation
- `[[` / `]]` / `][` / `[]` - function/block movement
- `[{` / `]}` / `[(` / `])` - block boundary movement
- `[/` / `]/` - comment movement
- `[m` / `]m` - method movement (C++/Java)
- `[I` / `[D` / `[d` / `[i` / `[<Tab>` - identifier search
- `gD` / `gd` - go to declaration

### Commands
- `:tag` / `:stag` / `:tselect` - tag jumping
- `:tnext` / `:tprevious` / `:tfirst` / `:tlast` - tag list navigation
- `:ptag` / `:pclose` / `:pedit` / `:psearch` - preview window
- `:checkpath` - check include files

---
---

# Neovim User Manual - Chapter 30 Extraction

Source: `usr_30.txt` - **Editing programs**

---

## 30.1 - Compiling
<!-- help: 30.1 | :h 30.1 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:make` | run make, capture errors, jump to first error | ✓ |
| `:cnext` / `:cprevious` | next/previous error | ✓ |
| `:cc` | show current error message | ✓ |
| `:cc {N}` | jump to error number N | ✓ |
| `:clist` | show all errors | ✓ |
| `:cfirst` / `:clast` | first/last error | ✓ |
| `:colder` / `:cnewer` | previous/next error list | ✓ |
| `:cfile {file}` | load errors from a file | ✓ |
| `:set makeprg={prog}` | change compiler program | ✗ |
| `:compiler {name}` | load compiler settings | ✓ |

---

## 30.2 - Indenting C style text
<!-- help: 30.2 | :h 30.2 -->

| Key    | Action                                  | Practice |
|--------|-----------------------------------------|----------|
| `==`   | Re-indent current line                  | ✓ |
| `=a{`  | Re-indent current `{}` block            | ✓ |
| `gg=G` | Re-indent entire file                   | ✓ |
| `=`    | Re-indent operator (with motion/visual) | ✓ |
| `>>`   | Shift current line right                | ✓ |
| `<<`   | Shift current line left                 | ✓ |
| `>i{`  | Indent inside current `{}` block        | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:set cindent` | enable C-style indentation | ✗ |
| `:set cinoptions=...` | customize C indentation style | ✗ |

---

## 30.3 - Automatic indenting
<!-- help: 30.3 | :h 30.3 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:filetype indent on` | enable filetype-based indentation | ✗ |
| `:filetype indent off` | disable filetype-based indentation | ✗ |

---

## 30.4 - Other indenting
<!-- help: 30.4 | :h 30.4 -->

Insert-mode keybindings:

| Key      | Action                                | Practice |
|----------|---------------------------------------|----------|
| `CTRL-T` | Add one shiftwidth of indent (Insert) | ✓ |
| `CTRL-D` | Remove one shiftwidth of indent (Insert) | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:set autoindent` | auto-indent new lines | ✗ |
| `:set smartindent` | smarter auto-indentation | ✗ |

---

## 30.5 - Tabs and spaces
<!-- help: 30.5 | :h 30.5 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:set softtabstop=4` | Tab key inserts 4-column indent | ✗ |
| `:set expandtab` / `:set noexpandtab` | spaces vs. real tabs | ✗ |
| `:set smarttab` | use shiftwidth for indent tabs | ✗ |
| `:%retab` | convert all indentation to current settings | ✓ |

---

## 30.6 - Formatting comments
<!-- help: 30.6 | :h 30.6 -->

| Key     | Action                                  | Practice |
|---------|-----------------------------------------|----------|
| `gq]/`  | Format a `/* */` comment               | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:set comments=...` | define comment markers | ✗ |

---

## Summary for Chapter 30

### Keybindings
- `==` / `=a{` / `gg=G` - re-indent
- `>>` / `<<` / `>i{` - shift indent
- Insert: `CTRL-T` / `CTRL-D` - adjust indent in Insert mode
- `gq]/` - format comment

### Commands
- `:make` - compile
- `:cnext` / `:cprevious` / `:cc` / `:clist` / `:cfirst` / `:clast` - quickfix
- `:colder` / `:cnewer` - error list history
- `:set cindent` / `:set cinoptions` - C indentation
- `:filetype indent on` - filetype indentation
- `:%retab` - convert tabs/spaces

---
---

# Neovim User Manual - Chapter 31 Extraction

Source: `usr_31.txt` - **Exploiting the GUI**

> GUI-specific chapter.

---

## 31.1 - The file browser
<!-- help: 31.1 | :h 31.1 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:browse edit` | open file browser to choose file | ✓ |
| `:browse split` | open file browser, then split with selected file | ✓ |
| `:confirm edit {file}` | edit file but prompt if unsaved changes | ✓ |

---

## Summary for Chapter 31

Primarily GUI-specific. Minor commands.

### Commands
- `:browse edit` / `:browse split` - file browser
- `:confirm edit` - confirm before discarding changes

---
---

# Neovim User Manual - Chapter 32 Extraction

Source: `usr_32.txt` - **The undo tree**

---

## 32.3 - Jumping around the tree
<!-- help: 32.3 | :h 32.3 -->

| Key  | Action                                | Practice |
|------|---------------------------------------|----------|
| `g-` | Move backward in time (across undo branches) | ✓ |
| `g+` | Move forward in time (across undo branches) | ✓ |

| Command | Action | Practice |
|---------|--------|----------|
| `:undo {N}` | jump to state below change number N | ✓ |

---

## 32.4 - Time travelling
<!-- help: 32.4 | :h 32.4 -->

| Command | Action | Practice |
|---------|--------|----------|
| `:earlier {N}s/m/h/d` | go back N seconds/minutes/hours/days | ✓ |
| `:later {N}s/m/h/d` | go forward N seconds/minutes/hours/days | ✓ |
| `:earlier 1f` | go back to state at last file write | ✓ |
| `:later 1f` | go forward to state at next file write | ✓ |
| `:undolist` | show all leaves of the undo tree | ✓ |

---

## Summary for Chapter 32

### Keybindings
- `g-` / `g+` - navigate undo tree across branches

### Commands
- `:undo {N}` - jump to specific undo state
- `:earlier` / `:later` - time-based undo navigation
- `:undolist` - show undo tree leaves
