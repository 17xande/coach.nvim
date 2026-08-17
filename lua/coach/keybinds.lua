-- Keybinding shadow detection and alternative keybind discovery

local M = {}

--- Convert a key string to internal bytes for reliable comparison.
---@param key string
---@return string
local function internal_key(key)
	return vim.api.nvim_replace_termcodes(key, true, true, true)
end

--- track-action.nvim, or nil if it is not installed.
---
--- Required at runtime, so this is nil only in a broken install or a test that does
--- not need it -- and in that case nothing is being tracked anyway, so the fallbacks
--- below degrade to today's behaviour rather than erroring in the render path.
---@return table|nil
local function track_action()
	local ok, commands = pcall(require, "track-action.commands")
	return ok and commands or nil
end

--- track-action's mapping resolver, or nil if it is not installed. Same reasoning
--- as `track_action` above.
---@return table|nil
local function track_action_mappings()
	local ok, mappings = pcall(require, "track-action.mappings")
	return ok and mappings or nil
end

--- The native keys an ex command is another name for: `vsplit` -> `<C-w>v`.
---
--- This is track-action's table, not a copy of it. coach kept its own 14 entries,
--- which had drifted from track-action's 28 -- `vnew`, `wincmd p` and the rest were
--- missing here, so a mapping to one of them was not recognised as an alternative
--- for the exercise it performs. The question in the TODO this replaces --- whether
--- these should come from the session --- answers itself: `:vsplit` is the same as
--- `<C-w>v` in every Vim, so it belongs with the plugin that reads Neovim's own
--- command tables, not in drill content.
---@param cmd string
---@return string|nil
local function native_for_ex(cmd)
	local mappings = track_action_mappings()
	return mappings and mappings.native_for_ex(cmd) or nil
end

--- The keys a user actually presses for an exercise: an action string minus the
--- decorations that are not keys. `f{char}` -> `f`, `[count]dw` -> `dw`.
---
--- Uses track-action's own function rather than a regex here. Both sides have to
--- agree on what an action string's bare keys are, and a second implementation is
--- how they stop agreeing.
---@param exercise string
---@return string
local function bare_keys(exercise)
	local commands = track_action()
	return commands and commands.strip_decoration(exercise) or exercise
end

--- The action string a key sequence produces, according to track-action's parser.
---
--- This is what makes a mapping to `5w` recognisable as an alternative for
--- `[count]w`: comparing the right-hand side to the exercise textually never
--- matches, because the exercise is an action string and the right-hand side is
--- keys. Feeding it to the same parser that emits the exercise answers exactly the
--- right question.
---@param keys string
---@return string|nil
local function action_for_keys(keys)
	local ok, parser_mod = pcall(require, "track-action.parser")
	if not ok then
		return nil
	end

	-- nvim_get_keymap hands back whatever was typed, which for a control key is the
	-- raw byte. keytrans() puts it in `<C-W>` notation, and track-action's parser is
	-- fed the tracker's own spelling, which is lower case.
	keys = vim.fn.keytrans(keys):gsub("<C%-(%a)>", function(c)
		return "<C-" .. c:lower() .. ">"
	end)

	local parser = parser_mod.new()
	local action
	local i = 1
	while i <= #keys do
		local key
		if keys:sub(i, i) == "<" then
			local close = keys:find(">", i, true)
			key = close and keys:sub(i, close) or keys:sub(i, i)
		else
			key = keys:sub(i, i)
		end
		i = i + #key
		local emitted = parser:feed_key(key, "n")
		if emitted then
			-- More than one action means the mapping is a sequence of commands, not
			-- another name for one, so it is not an alternative for any exercise.
			if action then
				return nil
			end
			action = emitted
		end
	end

	-- Keys left in the parser mean the sequence was incomplete.
	return action
end

--- Resolve a mapping RHS to a native key equivalent.
---@param rhs string The right-hand side of a mapping
---@return string|nil native The native key equivalent, or nil if unrecognizable
local function resolve_native(rhs)
	-- A right-hand side that runs an ex command comes in two spellings --
	-- `<Cmd>vsplit<CR>` and the older `:vsplit<CR>` -- and both mean "run this
	-- command", so the command text is pulled out of either and looked up as keys.
	-- The case in the patterns is whatever the mapping was defined with, hence
	-- `[Cc][Mm][Dd]`.
	local cmd_match = rhs:match("<[Cc][Mm][Dd]>(.+)<[Cc][Rr]>")
	if not cmd_match then
		cmd_match = rhs:match("^:(.+)<[Cc][Rr]>")
	end
	if cmd_match then
		return native_for_ex(cmd_match)
	end

	-- Direct key sequence (e.g. <C-h> mapped to <C-w>h): ask the parser what those
	-- keys do. That resolves `5w` to `[count]w` and `fx` to `f{char}`, and returns
	-- nil for a right-hand side that is not a command at all.
	if rhs ~= "" then
		return action_for_keys(rhs) or rhs
	end

	return nil
end

--- Format a key sequence for human-readable display.
---@param key string Key notation from nvim_get_keymap (e.g. "<C-H>", " sv")
---@return string
function M.format_key_display(key)
	-- Normalize leader prefix
	local leader = vim.g.mapleader
	if leader and #leader > 0 and vim.startswith(key, leader) and #key > #leader then
		key = "<leader>" .. key:sub(#leader + 1)
	end

	-- Convert <C-X> to Ctrl-X
	key = key:gsub("<C%-(%a)>", function(c)
		return "Ctrl-" .. c:upper()
	end)

	return key
end

--- Check if an exercise key is shadowed by a custom mapping in normal mode.
--- An exercise is shadowed when pressing it will NOT perform the expected action
--- because the user has remapped that key to do something else.
---
--- Returns: is_shadowed (bool), description (string|nil)
---
--- Asked of the action string, which may carry decorations -- `f{char}`, `[count]w`
--- -- that are not keys. maparg() finds nothing for those, so it is asked about the
--- bare keys instead. Without that a remapped `f` was never reported, and the
--- exercise sat there demanding reps for a key the user cannot press.
---@param exercise string The exercise action (e.g. "H", "<C-w>h", "f{char}")
---@return boolean, string|nil
function M.is_shadowed(exercise)
	exercise = bare_keys(exercise)
	local map_info = vim.fn.maparg(exercise, "n", false, true)

	-- No mapping: not shadowed
	if vim.tbl_isempty(map_info) then
		return false, nil
	end

	local rhs = map_info.rhs or ""

	-- Passthrough: rhs is the same key (just adds a description or noremap flag)
	if rhs == exercise then
		return false, nil
	end

	-- Count-expr motion pattern for single-char keys (e.g. j/k with wrapped-line
	-- handling). Pattern: v:count == 0 ? 'g<key>' : '<key>'
	--
	-- The length test is applied after stripping, which is what makes it reach
	-- `[count]j` -- the most commonly remapped counted motion, and precisely the
	-- exercise this escape hatch exists for, since the mapping's whole purpose is to
	-- keep the counted form behaving normally.
	if #exercise == 1 then
		local escaped = vim.pesc(exercise)
		local pattern = "v:count%s*==%s*0%s*%?%s*'g" .. escaped .. "'%s*:%s*'" .. escaped .. "'"
		if rhs:match(pattern) then
			return false, nil
		end
	end

	-- Either has a non-trivial rhs, or has a lua callback (rhs == "") — shadowed
	return true, map_info.desc
end

--- Get the map of shadowed exercises for a set.
---@param set table Set definition with .exercises list
---@return table<string, string|true> Map of exercise key → description (or true if no desc)
function M.get_shadowed(set)
	local shadowed = {}
	for _, e in ipairs(set.exercises) do
		local is_sh, desc = M.is_shadowed(e.exercise)
		if is_sh then
			shadowed[e.exercise] = desc or true
		end
	end
	return shadowed
end

--- Find alternative keybindings that perform the same action as the set's exercises.
--- Scans all normal-mode mappings and resolves their RHS to native equivalents.
---@param set table Set definition with .exercises list
---@return table<string, string[]> Map of exercise key → list of formatted alternative display strings
function M.get_alternatives(set)
	-- Build target set: internal_bytes → original exercise string
	local target_internal = {}
	for _, e in ipairs(set.exercises) do
		target_internal[internal_key(e.exercise)] = e.exercise
	end

	local all_maps = vim.api.nvim_get_keymap("n")
	-- Include buffer-local mappings
	local ok, buf_maps = pcall(vim.api.nvim_buf_get_keymap, 0, "n")
	if ok then
		for _, m in ipairs(buf_maps) do
			table.insert(all_maps, m)
		end
	end

	local alternatives = {}

	for _, map in ipairs(all_maps) do
		local lhs = map.lhs or ""
		local rhs = map.rhs or ""

		-- Skip if lhs IS an exercise key (that's the default, not an alternative)
		if target_internal[internal_key(lhs)] then
			goto continue
		end

		-- A <Plug> target is a plugin's internal name, and an expr mapping's rhs is an
		-- expression to evaluate rather than keys to press. Neither is a key sequence,
		-- so neither can be another name for a native command.
		if map.expr == 1 or rhs:find("<Plug>", 1, true) then
			goto continue
		end

		-- Try to resolve what native action this mapping performs
		local native = resolve_native(rhs)
		if native then
			local original = target_internal[internal_key(native)]
			if original then
				if not alternatives[original] then
					alternatives[original] = {}
				end
				table.insert(alternatives[original], M.format_key_display(lhs))
			end
		end

		::continue::
	end

	return alternatives
end

return M
