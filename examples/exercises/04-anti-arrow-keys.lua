-- Volume: Anti-Patterns — punish bad habits with negative rules.
--
-- Each chapter declares positive `actions` (what you want to practice) and
-- optional `negatives` (rules that decrement specific positive actions when
-- their triggers fire). Each rule has the shape:
--
--   {
--     triggers  = { "[4]l", "[2]<Right>" },  -- list of trigger strings
--     decrement = { "w", "W" },              -- positives to decrement on fire
--     message   = "Use w/W instead",         -- optional UI message
--   }
--
-- A trigger string may carry an `[N]` prefix that requires N *consecutive*
-- presses of that exact action before the rule fires. Without a prefix,
-- threshold defaults to 1. The streak resets on any non-trigger action
-- (positives, unrelated keys) or when a different trigger inside the same
-- rule is seen.
--
-- Action strings follow track-action.nvim's emit format:
--   "l"          → plain `l` with no count
--   "[count]l"   → counted `l`, e.g. `4l`, `7l`  (note: literal "[count]")
-- These are distinct triggers — `[count]l` is a separate emit from `l`.
--
-- Note: `<Right>`/`<Left>`/`<Home>`/`<End>` only fire if track-action.nvim
-- emits them as standalone actions in your environment. `h`/`l` are reliable.

return {
	{
		id = "anti.word",
		title = "Word Movement (no h/l spam!)",
		help_tag = "word-motions",
		actions = {
			{ action = "w", display = "w", desc = "Word forward" },
			{ action = "W", display = "W", desc = "WORD forward" },
			{ action = "b", display = "b", desc = "Word backward" },
			{ action = "B", display = "B", desc = "WORD backward" },
			{ action = "e", display = "e", desc = "Word end" },
		},
		negatives = {
			{
				-- 4 consecutive `l`, OR 2 consecutive right-arrows, OR any counted `l`
				triggers = { "[4]l", "[2]<Right>", "[count]l" },
				decrement = { "w", "W", "e" },
				message = "Use w/W/e instead of l",
			},
			{
				triggers = { "[4]h", "[2]<Left>", "[count]h" },
				decrement = { "b", "B" },
				message = "Use b/B instead of h",
			},
		},
	},
	{
		id = "anti.line",
		title = "Line Jumps (no Home/End)",
		help_tag = "line-motions",
		actions = {
			{ action = "^", display = "^", desc = "First non-blank" },
			{ action = "$", display = "$", desc = "Line end" },
			{ action = "f", display = "f{c}", desc = "Find char" },
		},
		negatives = {
			{
				triggers = { "<Home>" },
				decrement = { "^" },
				message = "Use ^ instead of Home",
			},
			{
				triggers = { "<End>" },
				decrement = { "$" },
				message = "Use $ instead of End",
			},
		},
	},
}
