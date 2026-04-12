-- Keybinding shadow detection and alternative keybind discovery

local M = {}

--TODO: Not sure what's happening here, shouldn't this be read from the current sesssion?
--What if the users' shortcuts are different?
--
--- Map of ex commands to their native key equivalents.
--- Used to detect alternative keybindings that resolve to exercise actions.
local ex_to_native = {
	["wincmd h"] = "<C-w>h",
	["wincmd j"] = "<C-w>j",
	["wincmd k"] = "<C-w>k",
	["wincmd l"] = "<C-w>l",
	["wincmd w"] = "<C-w>w",
	vsplit = "<C-w>v",
	vs = "<C-w>v",
	split = "<C-w>s",
	sp = "<C-w>s",
	close = "<C-w>c",
	only = "<C-w>o",
	["wincmd n"] = "<C-w>n",
	tabnext = "gt",
	tabprevious = "gT",
	tabprev = "gT",
}

--- Convert a key string to internal bytes for reliable comparison.
---@param key string
---@return string
local function internal_key(key)
	return vim.api.nvim_replace_termcodes(key, true, true, true)
end

--- Resolve a mapping RHS to a native key equivalent.
---@param rhs string The right-hand side of a mapping
---@return string|nil native The native key equivalent, or nil if unrecognizable
local function resolve_native(rhs)
	--TODO: don't know what's going on in here, get AI to explain.
	--
	-- Try <Cmd>...<CR> pattern
	local cmd_match = rhs:match("<[Cc][Mm][Dd]>(.+)<[Cc][Rr]>")
	if not cmd_match then
		-- Try :...<CR> pattern
		cmd_match = rhs:match("^:(.+)<[Cc][Rr]>")
	end
	if cmd_match then
		return ex_to_native[vim.trim(cmd_match)]
	end

	-- Direct key sequence: return the RHS itself as a potential native key
	-- (e.g. <C-h> mapped to <C-w>h directly)
	if rhs ~= "" then
		return rhs
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

--- Check if an action key is shadowed by a custom mapping in normal mode.
--- An action is shadowed when pressing it will NOT perform the expected exercise action
--- because the user has remapped that key to do something else.
---
--- Returns: is_shadowed (bool), description (string|nil)
---@param action string The action key (e.g. "H", "<C-w>h", "gt")
---@return boolean, string|nil
function M.is_shadowed(action)
	local map_info = vim.fn.maparg(action, "n", false, true)

	-- No mapping: not shadowed
	if vim.tbl_isempty(map_info) then
		return false, nil
	end

	local rhs = map_info.rhs or ""

	-- Passthrough: rhs is the same key (just adds a description or noremap flag)
	if rhs == action then
		return false, nil
	end

	-- Count-expr motion pattern for single-char keys (e.g. j/k with wrapped-line handling)
	-- Pattern: v:count == 0 ? 'g<key>' : '<key>'
	if #action == 1 then
		local escaped = vim.pesc(action)
		local pattern = "v:count%s*==%s*0%s*%?%s*'g" .. escaped .. "'%s*:%s*'" .. escaped .. "'"
		if rhs:match(pattern) then
			return false, nil
		end
	end

	-- Either has a non-trivial rhs, or has a lua callback (rhs == "") — shadowed
	return true, map_info.desc
end

--- Get the set of shadowed actions for an exercise.
---@param exercise table Exercise definition with .actions list
---@return table<string, string|true> Map of action key → description (or true if no desc)
function M.get_shadowed(exercise)
	local shadowed = {}
	for _, a in ipairs(exercise.actions) do
		local is_sh, desc = M.is_shadowed(a.action)
		if is_sh then
			shadowed[a.action] = desc or true
		end
	end
	return shadowed
end

--- Find alternative keybindings that perform the same action as exercise actions.
--- Scans all normal-mode mappings and resolves their RHS to native equivalents.
---@param exercise table Exercise definition with .actions list
---@return table<string, string[]> Map of action key → list of formatted alternative display strings
function M.get_alternatives(exercise)
	-- Build target set: internal_bytes → original action string
	local target_internal = {}
	for _, a in ipairs(exercise.actions) do
		target_internal[internal_key(a.action)] = a.action
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

		-- Skip if lhs IS an exercise action (that's the default, not an alternative)
		if target_internal[internal_key(lhs)] then
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
