-- Keybinds learned from what the user actually pressed.
--
-- If you have your own mapping for an exercise, pressing it counts -- Neovim reports
-- the command your mapping ran, so that side needs no help at all. What needed help
-- was *showing* the mapping in the window beside the default keys.
--
-- That used to be a static scan: read every normal-mode mapping at render time, run
-- each right-hand side through track-action's parser, and compare the action it
-- produced. Comparing the text never worked, because one side is keys and the other
-- an action string. It worked for `<leader>W` -> `5w`, and it could never work for a
-- Lua-callback mapping, whose right-hand side is not keys at all.
--
-- The replacement arrives from the other direction: every atom a mapping produces
-- carries its `lhs`, so an alternative is **learned the first time the user presses
-- it**. Nothing is interpreted -- the editor already told us both halves, what ran
-- and what was pressed -- so a mapping to `5w` and a mapping to `<C-w>v` are the
-- same case, and there is no rhs to fail to understand.
--
-- The cost is that a mapping is not listed until it has been used once. That is the
-- right trade: a list of every mapping that *might* be an alternative was noise, and
-- the one the user reaches for is the one worth showing.
--
-- **Two kinds of mapping still cannot be learned, and are not the scan's fault
-- either -- it could not reach them.** Both are asserted in `tests/e2e_spec.lua` so
-- they are not rediscovered as bugs:
--
--   * **A Lua-callback mapping.** It reports `type="mapping"` with an empty `keys`
--     and no `cmd`: Neovim says a mapping ran and says nothing about what it did,
--     because a `:normal` inside the callback is programmatic input and publishes no
--     atom. So the exercise is not credited and there is nothing to attach.
--   * **A `<Cmd>` mapping**, which is the spelling `:help <Cmd>` recommends. It
--     avoids the cmdline events, and avoiding them is what loses the command --
--     `<Cmd>nohlsearch<CR>` reports only that a mapping ran. The older
--     `:nohlsearch<CR>` spelling is reported in full and works.
--
-- Persisted beside `state.json` rather than beside a session's progress, because a
-- mapping is a property of the user's config and applies to every session.

local M = {}

--- Bumped when the meaning of a stored key changes. A file from another version is
--- **discarded**, not converted -- the house rule, and cheap here: re-learning costs
--- one keypress.
M.CURRENT_VERSION = 1

--- Where the file lives, unless `setup` overrides it -- which `coach.setup` always
--- does, deriving it from the progress root's parent so that a redirected
--- `progress_dir` cannot leave a test writing over the real one.
local DEFAULT_PATH = vim.fn.stdpath("data") .. "/coach/alternatives.json"

--- exercise -> { [lhs] = true }
---@type table<string, table<string, boolean>>
local learned = {}

--- The file currently in use.
local path = DEFAULT_PATH

--- Whether anything has changed since the last write.
local dirty = false

--- Debounce timer, allocated once and restarted. A rep is a keystroke, so a write per
--- press is too much -- the same reasoning as `progress.schedule_save`.
local timer = nil

--- How long after the last change to write, in ms.
local SAVE_DELAY = 2000

--- track-action's decoration stripper, or a passthrough if it is not installed.
---
--- Shared rather than reimplemented so that "what keys is this exercise" has one
--- answer here and in shadow detection. Degrades to the action string itself, which
--- is only wrong for a decorated exercise and only means one redundant row.
---@param exercise string
---@return string
local function bare_keys(exercise)
	local ok, commands = pcall(require, "track-action.commands")
	if not ok then
		return exercise
	end
	return commands.strip_decoration(exercise)
end

--- Read the file, or start empty.
---
--- Every failure path starts empty rather than erroring: this is a convenience
--- cache, and a corrupt one must not stop coaching.
local function load()
	learned = {}
	local f = io.open(path, "r")
	if not f then
		return
	end
	local content = f:read("*a")
	f:close()

	local ok, data = pcall(vim.json.decode, content)
	if not ok or type(data) ~= "table" then
		return
	end
	if data.version ~= M.CURRENT_VERSION then
		return
	end
	if type(data.alternatives) ~= "table" then
		return
	end

	for exercise, list in pairs(data.alternatives) do
		if type(exercise) == "string" and type(list) == "table" then
			learned[exercise] = {}
			for _, lhs in ipairs(list) do
				if type(lhs) == "string" and lhs ~= "" then
					learned[exercise][lhs] = true
				end
			end
		end
	end
end

--- Point at a file and load it. Called from `setup()`, and by the specs to redirect
--- away from the user's real one.
---@param opts? { path?: string }
function M.setup(opts)
	opts = opts or {}
	path = opts.path or DEFAULT_PATH
	dirty = false
	load()
end

--- Write now, if there is anything to write.
---
--- Deliberately writes nothing when nothing has been learned, so that "has this user
--- ever mapped an exercise" stays answerable from the filesystem rather than every
--- startup creating an empty file.
function M.flush()
	if timer then
		timer:stop()
	end
	if not dirty then
		return
	end

	local out = {}
	for exercise, set in pairs(learned) do
		local list = vim.tbl_keys(set)
		table.sort(list)
		if #list > 0 then
			out[exercise] = list
		end
	end

	local dir = vim.fn.fnamemodify(path, ":h")
	if vim.fn.isdirectory(dir) == 0 then
		pcall(vim.fn.mkdir, dir, "p")
	end
	local f = io.open(path, "w")
	if not f then
		return
	end
	f:write(vim.json.encode({ version = M.CURRENT_VERSION, alternatives = out }))
	f:close()
	dirty = false
end

--- Restart the debounce. One timer, reused: this runs on a keypress, so allocating a
--- handle here would leak one per press.
local function schedule_save()
	if not timer then
		timer = vim.uv.new_timer()
	end
	if not timer then
		M.flush()
		return
	end
	timer:stop()
	timer:start(
		SAVE_DELAY,
		0,
		vim.schedule_wrap(function()
			M.flush()
		end)
	)
end

--- Record that `lhs` performed `exercise`.
---
--- Ignores the exercise's own keys: pressing `w` reports no lhs at all, but a mapping
--- of `w` to something that still performs `w` does, and listing `w` as an
--- alternative for `w` is noise. Compared against the *bare* keys, so `3w` is not
--- listed as an alternative for `[count]w` and `fa` not for `f{char}`.
---@param exercise string
---@param lhs string|nil
function M.learn(exercise, lhs)
	if type(exercise) ~= "string" or type(lhs) ~= "string" or lhs == "" then
		return
	end
	if lhs == exercise or lhs == bare_keys(exercise) then
		return
	end

	local set = learned[exercise]
	if not set then
		set = {}
		learned[exercise] = set
	end
	if set[lhs] then
		return
	end
	set[lhs] = true
	dirty = true
	schedule_save()
end

--- The mappings learned for one exercise, sorted.
---
--- Sorted because the window puts them on a line, and a line that reorders itself
--- between renders reads as though something changed.
---@param exercise string|nil
---@return string[]
function M.for_exercise(exercise)
	if type(exercise) ~= "string" then
		return {}
	end
	local set = learned[exercise]
	if not set then
		return {}
	end
	local list = vim.tbl_keys(set)
	table.sort(list)
	return list
end

--- Every learned mapping for the exercises of `set`, as the window wants them.
---
--- An exercise with none is absent rather than mapped to an empty list, which is what
--- lets the render path test `alternatives[e.exercise]` truthily.
---@param set table|nil Set definition with an `exercises` list
---@return table<string, string[]>
function M.get(set)
	local out = {}
	for _, e in ipairs((set or {}).exercises or {}) do
		local list = M.for_exercise(e.exercise)
		if #list > 0 then
			out[e.exercise] = list
		end
	end
	return out
end

--- Forget everything.
function M.clear()
	learned = {}
	dirty = true
	schedule_save()
end

return M
