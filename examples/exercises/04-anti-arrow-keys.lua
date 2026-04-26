-- Volume: Anti-Patterns — punish bad habits with negative triggers.
--
-- Each chapter declares positive `actions` (what you want to practice) and
-- optional `negatives` (keys that, when pressed, decrement *every* positive
-- action's count for that exercise — floored at zero).
--
-- A negative may also declare `threshold = N`. The decrement only fires
-- after N *consecutive* presses of that exact action. Pressing anything
-- else (a positive action, a different negative, an unrelated key) resets
-- the streak. This lets you tolerate occasional `l` use while still
-- punishing reflex spam.
--
-- The `action` field follows track-action.nvim's emit format:
--   - "l"          → plain `l` with no count
--   - "[count]l"   → counted `l`, e.g. `4l`, `7l`
-- These are distinct triggers — pick the one that matches the habit you
-- want to stamp out.
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
			-- 4 consecutive `l` presses → decrement. Occasional `l` is fine.
			{ action = "l", display = "l", desc = "Use w/e/W after 4 in a row", threshold = 4 },
			{ action = "h", display = "h", desc = "Use b/B after 4 in a row", threshold = 4 },
			-- Counted forms are a separate emit from track-action: any `[count]l`
			-- (e.g. `4l`, `12l`) decrements immediately — too lazy.
			{ action = "[count]l", display = "{N}l", desc = "Use w/W instead" },
			{ action = "[count]h", display = "{N}h", desc = "Use b/B instead" },
			-- Arrow keys: zero tolerance.
			{ action = "<Right>", display = "→", desc = "No arrow keys" },
			{ action = "<Left>",  display = "←", desc = "No arrow keys" },
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
			{ action = "<Home>", display = "Home", desc = "Use ^ instead" },
			{ action = "<End>",  display = "End",  desc = "Use $ instead" },
		},
	},
}
