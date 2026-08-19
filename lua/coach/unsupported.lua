-- The exercises Neovim cannot report, and the five that are worse than dead.
--
-- Fifteen of the 333 builtin exercises can never be credited. Every one is a
-- deliberate property of Neovim's action model rather than a gap in either plugin,
-- and none can be worked around here -- an action is the material dot-repeat
-- replays, so a key defined as a translation of another reports the translation.
--
-- They are labelled `unsupported` in the window and **excluded from set
-- completion**. That exclusion is the load-bearing part: without it a set holding
-- one of these blocks `:CoachNext` forever and nothing says why, which is the exact
-- failure the emit fence was built to catch.
--
-- **This list is not maintained by hand alone.** track-action's
-- `tests/vocabulary_spec.lua` types all 333 exercises into a real Neovim and asserts
-- each of these *fails* to render as itself, then checks this table against its own.
-- So the day upstream makes one work, the fence says to promote it rather than
-- quietly continuing to skip it.
--
-- Two things deliberately absent, both easy to add back by mistake:
--
--   * **`<C-i>`.** Neovim names that byte `<Tab>`, which is a naming difference and
--     not something it cannot report -- the user performs the jump perfectly well.
--     The drill is spelled `<Tab>`, with `display` still reading `Ctrl-I` because
--     that is what the manual writes.
--   * **`%`, `[count]%` and `Y`.** matchit ships mapped to `%`, so pressing it
--     performs an ex call, and `Y` is a default mapping to `y$`. In both cases the
--     atom names *what ran* and only the mapping's `lhs` names what was pressed --
--     which `resolve_match_action` consults, so all three are creditable.

local M = {}

--- Why each exercise can never be credited.
---
--- The first group is `nv_optrans`: Neovim's own `dev_arch.txt` says it outright --
--- *"'x' is captured as 'dl'"*.
M.ACTIONS = {
	-- Reported as the command they are defined to perform.
	["x"] = "Neovim reports this as `dl`",
	["[count]x"] = "Neovim reports this as `[count]dl`",
	["X"] = "Neovim reports this as `dh`",
	["s"] = "Neovim reports this as `cl`",
	["C"] = "Neovim reports this as `c$`",
	["S"] = "Neovim reports this as `cc`",
	["D"] = "Neovim reports this as `d$`",
	["do"] = "diff-obtain is reported as plain `o`",
	["dp"] = "diff-put is reported as plain `p`",
	-- An uncompleted Visual selection is a SPAN, and a SPAN cascades without
	-- emitting. Only a completed sequence like `viwd` reports anything.
	--
	-- `gv` is the trap in this group: a *failed* `gv` -- nothing to reselect -- does
	-- report an atom named `gv`, so it looks creditable until you give it something
	-- to reselect, at which point it reports nothing.
	["v"] = "starting a Visual selection reports nothing until the selection is used",
	["V"] = "starting a Visual selection reports nothing until the selection is used",
	["<C-v>"] = "starting a Visual selection reports nothing until the selection is used",
	["gv"] = "reselecting reports nothing, for the same reason as `v`",
	-- No provenance field anywhere in the payload: a dot-repeat is reported
	-- field-for-field identically to the action it repeats.
	["."] = "a repeat is reported identically to the action it repeats",
	-- Opens a cmdline; the completed action is the ex command typed into it.
	["!!"] = "this opens a command line, and completes as `ex:!` -- which is drilled",
}

--- The drill that actually moves when one of these is pressed.
---
--- **The part to remember.** Where a translation is *itself* a drilled exercise,
--- pressing the key credits the other drill: a silent false *positive*, which is
--- worse than a dead row because the window shows progress that was not earned. No
--- label fixes that -- only knowing about it.
---
--- `x` -> `dl`, `X` -> `dh`, `s` -> `cl` and `C` -> `c$` are real translations too,
--- and harmless only because those spellings are not drilled. They have no entry
--- here, and `unsupported_spec` asserts that every entry that *is* here names
--- something the manual really drills -- so if a target stops being drilled, the
--- hazard is gone and the entry should go with it.
---
--- `.` is a hazard with no fixed target: it credits whatever it repeated. Not listed
--- here for that reason, and mitigated by luck rather than design -- the tracker's
--- 3-deep cooldown ring refuses the same action twice within the last three, so
--- `dw.` credits `dw` once.
M.CREDITS = {
	["S"] = "cc",
	["D"] = "d$",
	["do"] = "o",
	["dp"] = "p",
}

--- Can this exercise never be credited?
---@param action string|nil
---@return boolean
function M.is(action)
	return type(action) == "string" and M.ACTIONS[action] ~= nil
end

--- Why, or nil if the exercise is creditable.
---@param action string|nil
---@return string|nil
function M.reason(action)
	if type(action) ~= "string" then
		return nil
	end
	return M.ACTIONS[action]
end

--- The drill this exercise credits instead, or nil if it credits nothing.
---@param action string|nil
---@return string|nil
function M.credits(action)
	if type(action) ~= "string" then
		return nil
	end
	return M.CREDITS[action]
end

--- Every unsupported exercise in `set`, as a map the window and progress can index.
---
--- Same shape as `keybinds.get_shadowed`, so the two can be unioned without either
--- caller knowing which is which.
---@param set table Set definition with an `exercises` list
---@return table<string, string> exercise -> reason
function M.get(set)
	local out = {}
	for _, e in ipairs((set or {}).exercises or {}) do
		local reason = M.reason(e.exercise)
		if reason then
			out[e.exercise] = reason
		end
	end
	return out
end

return M
