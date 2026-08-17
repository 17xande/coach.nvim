local h = require("harness")
local describe, it, eq, is_true, is_false = h.describe, h.it, h.eq, h.is_true, h.is_false

-- The tracker module depends on track-action.nvim at runtime,
-- but we can test its anti-spam logic by simulating the callback flow.
-- We do this by re-implementing the cooldown logic in isolation.

describe("tracker anti-spam logic", function()
	-- Mirror the tracker's cooldown logic for unit testing
	local COOLDOWN = 3
	local recent_actions = {}

	local function push_recent(action)
		table.insert(recent_actions, action)
		if #recent_actions > COOLDOWN then
			table.remove(recent_actions, 1)
		end
	end

	local function is_on_cooldown(action)
		for _, recent in ipairs(recent_actions) do
			if recent == action then
				return true
			end
		end
		return false
	end

	local function reset()
		recent_actions = {}
	end

	describe("cooldown ring buffer", function()
		it("empty buffer has no cooldowns", function()
			reset()
			is_false(is_on_cooldown("h"))
			is_false(is_on_cooldown("j"))
		end)

		it("action is on cooldown immediately after push", function()
			reset()
			push_recent("h")
			is_true(is_on_cooldown("h"))
		end)

		it("different action is not on cooldown", function()
			reset()
			push_recent("h")
			is_false(is_on_cooldown("j"))
		end)

		it("action falls off after COOLDOWN other actions", function()
			reset()
			push_recent("h")
			is_true(is_on_cooldown("h"))
			push_recent("j")
			push_recent("k")
			push_recent("l")
			-- "h" should now be evicted (buffer: j, k, l)
			is_false(is_on_cooldown("h"))
		end)

		it("buffer holds exactly COOLDOWN items", function()
			reset()
			push_recent("a")
			push_recent("b")
			push_recent("c")
			eq(3, #recent_actions)
			push_recent("d")
			eq(3, #recent_actions)
			-- "a" should be gone
			is_false(is_on_cooldown("a"))
			is_true(is_on_cooldown("b"))
			is_true(is_on_cooldown("c"))
			is_true(is_on_cooldown("d"))
		end)

		it("consecutive same action stays on cooldown", function()
			reset()
			push_recent("h")
			push_recent("h")
			push_recent("h")
			is_true(is_on_cooldown("h"))
			-- one more different action is not enough
			push_recent("j")
			is_true(is_on_cooldown("h"))
		end)

		it("non-exercise actions clear cooldown too", function()
			reset()
			push_recent("h") -- exercise action
			push_recent("w") -- non-exercise action
			push_recent("b") -- non-exercise action
			push_recent("e") -- non-exercise action
			-- "h" should be evicted
			is_false(is_on_cooldown("h"))
		end)
	end)

	describe("spam scenario", function()
		it("spamming h only counts once per cooldown window", function()
			reset()
			local counted = 0
			-- Simulate: user spams "h" 10 times
			for _ = 1, 10 do
				if not is_on_cooldown("h") then
					counted = counted + 1
				end
				push_recent("h")
			end
			-- only the first one should count
			eq(1, counted)
		end)

		it("alternating actions all count", function()
			reset()
			local counted = 0
			-- Simulate: h, j, k, l, h, j, k, l
			local actions = { "h", "j", "k", "l", "h", "j", "k", "l" }
			for _, action in ipairs(actions) do
				if not is_on_cooldown(action) then
					counted = counted + 1
				end
				push_recent(action)
			end
			-- all 8 should count (cooldown is 3, rotation is 4)
			eq(8, counted)
		end)

		it("two-action alternation does not count", function()
			reset()
			local counted = 0
			-- Simulate: h, j, h, j, h, j
			local actions = { "h", "j", "h", "j", "h", "j" }
			for _, action in ipairs(actions) do
				if not is_on_cooldown(action) then
					counted = counted + 1
				end
				push_recent(action)
			end
			-- h: counted at pos 1, on cooldown at 3 (buffer: h,j,h), counted=2 for h? Let me trace:
			-- pos1: h, buffer empty, not on cooldown -> count. push h. buffer: [h]. counted=1
			-- pos2: j, not on cooldown -> count. push j. buffer: [h,j]. counted=2
			-- pos3: h, buffer [h,j], h is in buffer -> skip. push h. buffer: [h,j,h]. counted=2
			-- pos4: j, buffer [h,j,h], j is in buffer -> skip. push j. buffer: [j,h,j]. counted=2
			-- pos5: h, buffer [j,h,j], h is in buffer -> skip. push h. buffer: [h,j,h]. counted=2
			-- pos6: j, buffer [h,j,h], j is in buffer -> skip. push j. buffer: [j,h,j]. counted=2
			eq(2, counted)
		end)
	end)
end)

describe("resolve_match_action", function()
	-- Test the function that decides which action string to use for exercise matching.
	-- Given the action from track-action and the data table (which may include data.native),
	-- resolve_match_action returns the string to match against the exercise action set.

	local function fresh_tracker()
		package.loaded["coach.tracker"] = nil
		return require("coach.tracker")
	end

	it("returns data.native when present", function()
		local tracker = fresh_tracker()
		local result = tracker.resolve_match_action("ex:vsplit", { native = "<C-w>v" })
		eq("<C-w>v", result)
	end)

	it("falls back to action when data.native is nil", function()
		local tracker = fresh_tracker()
		local result = tracker.resolve_match_action("<C-w>v", { native = nil })
		eq("<C-w>v", result)
	end)

	it("falls back to action when data.native is absent", function()
		local tracker = fresh_tracker()
		local result = tracker.resolve_match_action("h", {})
		eq("h", result)
	end)

	it("falls back to action when data is nil", function()
		local tracker = fresh_tracker()
		local result = tracker.resolve_match_action("h", nil)
		eq("h", result)
	end)

	it("uses native for remapped window commands", function()
		local tracker = fresh_tracker()
		-- Simulates: <C-h> mapped to <cmd>wincmd h<cr>, track-action emits ex:wincmd
		-- with native = "<C-w>h"
		local result = tracker.resolve_match_action("<C-h>", { native = "<C-w>h" })
		eq("<C-w>h", result)
	end)

	-- Preferring `native` unconditionally made every ex exercise with a native
	-- equivalent uncreditable: set 08.1 drills `:split`, `:close`, `:new`, and
	-- track-action reports each of those with native = `<C-w>s`/`<C-w>c`/`<C-w>n`,
	-- so what coach matched on was never what the set asked for. The set decides
	-- which spelling it is drilling; both remain acceptable.
	describe("when the current set says which spelling it wants", function()
		it("credits the ex form when that is what the set drills", function()
			local tracker = fresh_tracker()
			local result = tracker.resolve_match_action("ex:split", { native = "<C-w>s" }, { ["ex:split"] = true })
			eq("ex:split", result)
		end)

		it("credits the native form when that is what the set drills", function()
			local tracker = fresh_tracker()
			local result = tracker.resolve_match_action("ex:split", { native = "<C-w>s" }, { ["<C-w>s"] = true })
			eq("<C-w>s", result)
		end)

		it("still prefers native when the set drills neither", function()
			-- Unchanged: an alternative keybind is resolved further down, and that
			-- lookup is keyed on the native form.
			local tracker = fresh_tracker()
			local result = tracker.resolve_match_action("ex:split", { native = "<C-w>s" }, { ["w"] = true })
			eq("<C-w>s", result)
		end)

		it("is unaffected for an action with no native equivalent", function()
			local tracker = fresh_tracker()
			eq("ex:quit", tracker.resolve_match_action("ex:quit", {}, { ["ex:quit"] = true }))
		end)
	end)
end)

describe("parse_trigger", function()
	local function fresh()
		package.loaded["coach.tracker"] = nil
		return require("coach.tracker")
	end

	it("parses plain action with default threshold 1", function()
		local t = fresh()
		local act, n = t._parse_trigger("l")
		eq("l", act)
		eq(1, n)
	end)

	it("parses [N] prefix", function()
		local t = fresh()
		local act, n = t._parse_trigger("[4]l")
		eq("l", act)
		eq(4, n)
	end)

	it("preserves [count] literal as part of the action", function()
		local t = fresh()
		local act, n = t._parse_trigger("[count]l")
		eq("[count]l", act)
		eq(1, n)
	end)

	it("[N] prefix combines with [count] action", function()
		local t = fresh()
		local act, n = t._parse_trigger("[3][count]l")
		eq("[count]l", act)
		eq(3, n)
	end)

	it("works with bracketed special keys", function()
		local t = fresh()
		local act, n = t._parse_trigger("[2]<Right>")
		eq("<Right>", act)
		eq(2, n)
	end)
end)

describe("negative rules (_tick_rules)", function()
	local function fresh()
		package.loaded["coach.tracker"] = nil
		return require("coach.tracker")
	end

	local function rules_for(t, exercise)
		return t._compile_rules_for(exercise)
	end

	it("threshold default 1 fires on first press", function()
		local t = fresh()
		local rules = rules_for(t, {
			negatives = { { triggers = { "l" }, decrement = { "w" } } },
		})
		local fired = t._tick_rules("l", rules)
		eq(1, #fired)
	end)

	it("threshold [N] requires N consecutive presses", function()
		local t = fresh()
		local rules = rules_for(t, {
			negatives = { { triggers = { "[4]l" }, decrement = { "w" } } },
		})
		eq(0, #t._tick_rules("l", rules))
		eq(0, #t._tick_rules("l", rules))
		eq(0, #t._tick_rules("l", rules))
		eq(1, #t._tick_rules("l", rules))
	end)

	it("after firing, streak resets", function()
		local t = fresh()
		local rules = rules_for(t, {
			negatives = { { triggers = { "[3]l" }, decrement = { "w" } } },
		})
		t._tick_rules("l", rules)
		t._tick_rules("l", rules)
		eq(1, #t._tick_rules("l", rules)) -- fires
		eq(0, #t._tick_rules("l", rules)) -- 1 of next streak
		eq(0, #t._tick_rules("l", rules))
		eq(1, #t._tick_rules("l", rules)) -- fires
	end)

	it("non-trigger action resets the streak", function()
		local t = fresh()
		local rules = rules_for(t, {
			negatives = { { triggers = { "[4]l" }, decrement = { "w" } } },
		})
		t._tick_rules("l", rules)
		t._tick_rules("l", rules)
		t._tick_rules("l", rules) -- streak=3
		t._tick_rules("w", rules) -- not a trigger → reset
		eq(0, #t._tick_rules("l", rules))
		eq(0, #t._tick_rules("l", rules))
		eq(0, #t._tick_rules("l", rules))
		eq(1, #t._tick_rules("l", rules)) -- streak=4 fires
	end)

	it("different trigger inside same rule restarts streak at 1", function()
		local t = fresh()
		local rules = rules_for(t, {
			negatives = { { triggers = { "[4]l", "[4]<Right>" }, decrement = { "w" } } },
		})
		t._tick_rules("l", rules)
		t._tick_rules("l", rules) -- l streak=2
		eq(0, #t._tick_rules("<Right>", rules)) -- restart at 1 for <Right>
		eq(0, #t._tick_rules("<Right>", rules))
		eq(0, #t._tick_rules("<Right>", rules))
		eq(1, #t._tick_rules("<Right>", rules)) -- fires
	end)

	it("two distinct triggers in one rule each fire at their own threshold", function()
		local t = fresh()
		local rules = rules_for(t, {
			negatives = { { triggers = { "[4]l", "[2]<Right>" }, decrement = { "w" } } },
		})
		eq(0, #t._tick_rules("<Right>", rules))
		eq(1, #t._tick_rules("<Right>", rules)) -- fires at 2
	end)

	it("rules are independent across the negatives list", function()
		local t = fresh()
		local rules = rules_for(t, {
			negatives = {
				{ triggers = { "[2]l" }, decrement = { "w" } },
				{ triggers = { "[3]h" }, decrement = { "b" } },
			},
		})
		eq(0, #t._tick_rules("l", rules))
		local fired = t._tick_rules("l", rules)
		eq(1, #fired)
		eq("w", fired[1].decrement[1])

		eq(0, #t._tick_rules("h", rules))
		eq(0, #t._tick_rules("h", rules))
		local fired2 = t._tick_rules("h", rules)
		eq(1, #fired2)
		eq("b", fired2[1].decrement[1])
	end)

	it("[count]l is a separate trigger from plain l", function()
		local t = fresh()
		local rules = rules_for(t, {
			negatives = {
				{ triggers = { "[4]l", "[count]l" }, decrement = { "w" } },
			},
		})
		t._tick_rules("l", rules)
		t._tick_rules("l", rules) -- l streak=2, below threshold 4
		eq(1, #t._tick_rules("[count]l", rules)) -- counted variant fires immediately
	end)

	it("non-trigger action does not fire and does not stop later rules", function()
		local t = fresh()
		local rules = rules_for(t, {
			negatives = { { triggers = { "l" }, decrement = { "w" } } },
		})
		eq(0, #t._tick_rules("w", rules)) -- positive press, no fire
		eq(1, #t._tick_rules("l", rules)) -- still fires
	end)

	it("fired rule carries decrement list and message", function()
		local t = fresh()
		local rules = rules_for(t, {
			negatives = {
				{ triggers = { "l" }, decrement = { "w", "W" }, message = "use w/W" },
			},
		})
		local fired = t._tick_rules("l", rules)
		eq(1, #fired)
		eq("use w/W", fired[1].message)
		eq(2, #fired[1].decrement)
		eq("w", fired[1].decrement[1])
		eq("W", fired[1].decrement[2])
	end)
end)

describe("tracker module", function()
	it("is_active returns false initially", function()
		-- force fresh load
		package.loaded["coach.tracker"] = nil
		local tracker = require("coach.tracker")
		is_false(tracker.is_active())
	end)

	it("set_next_key does not crash", function()
		package.loaded["coach.tracker"] = nil
		local tracker = require("coach.tracker")
		tracker.set_next_key("<leader>kn")
	end)
end)

describe("resolve_alternative", function()
	-- Test that alternative keybindings (e.g. <leader>| -> <C-w>v) are resolved
	-- to the canonical exercise for counting purposes.

	local set = {
		id = "test.alt",
		title = "T",
		exercises = { { exercise = "<C-w>v", display = "Ctrl-W v", desc = "Split" } },
	}

	it("get_alternatives finds a direct-key RHS mapping as an alternative", function()
		-- Set a known leader so format_key_display normalises correctly.
		local orig_leader = vim.g.mapleader
		vim.g.mapleader = " "
		vim.keymap.set("n", "<leader>X", "<C-w>v", { desc = "Test split" })

		package.loaded["coach.keybinds"] = nil
		local keybinds = require("coach.keybinds")
		local alts = keybinds.get_alternatives(set)
		local found = alts["<C-w>v"] and vim.tbl_contains(alts["<C-w>v"], "<leader>X")
		is_true(found == true, "expected <leader>X in alternatives for <C-w>v")

		vim.keymap.del("n", "<leader>X")
		vim.g.mapleader = orig_leader
	end)

	it("get_alternatives does not list unmapped keys", function()
		package.loaded["coach.keybinds"] = nil
		local keybinds = require("coach.keybinds")
		local alts = keybinds.get_alternatives(set)
		local found = alts["<C-w>v"] and vim.tbl_contains(alts["<C-w>v"], "<leader>NOPE_XYZ")
		is_true(not found, "unmapped key should not appear as alternative")
	end)
end)

-- =========================================================================
-- Per-set caches are scoped to the session, not to the id
-- =========================================================================
--
-- Set ids are unique within a session, not across programs: a third-party
-- program is free to ship its own "03.1". Keyed on the id alone, the compiled
-- negative rules and the alternatives map of one session's 03.1 were served for
-- another's.

describe("per-set cache keys", function()
	--- One session file holding a single set with the given id and one negative
	--- rule, so two sessions can collide on the id while differing in content.
	local function make_program(id, trigger)
		local dir = vim.fn.tempname() .. "_coach_collide"
		vim.fn.mkdir(dir, "p")
		local f = assert(io.open(dir .. "/only.lua", "w"))
		f:write(([[
return {
  {
    id = %q,
    title = "Collides",
    exercises = { { exercise = "w", display = "w", desc = "Word" } },
    negatives = { { triggers = { %q }, decrement = { "w" } } },
  },
}
]]):format(id, trigger))
		f:close()
		return dir
	end

	local function fresh()
		for _, mod in ipairs({ "coach.sets", "coach.programs", "coach.sources", "coach.builtin", "coach.tracker" }) do
			package.loaded[mod] = nil
		end
		local programs = require("coach.programs")
		programs._set_state_file(vim.fn.tempname() .. "_coach_collide_state.json")
		return programs, require("coach.tracker")
	end

	it("two sessions sharing a set id get their own compiled rules", function()
		local programs, tracker = fresh()
		local dir_a = make_program("03.1", "l")
		local dir_b = make_program("03.1", "h")

		programs.configure({
			programs = { { name = "a", source = dir_a }, { name = "b", source = dir_b } },
			active = "a/only",
		})
		local rules_a = tracker._compiled_rules_for_active()
		eq(1, rules_a[1] and rules_a[1].triggers.l and 1 or 0, "session a's trigger is l")

		programs.switch("b", "only")
		local rules_b = tracker._compiled_rules_for_active()
		eq(1, rules_b[1] and rules_b[1].triggers.h and 1 or 0, "session b's trigger is h")
		eq(nil, rules_b[1] and rules_b[1].triggers.l, "and not session a's")
	end)

	it("the cache key names the session as well as the set", function()
		local programs, tracker = fresh()
		local dir_a = make_program("03.1", "l")
		programs.configure({ programs = { { name = "a", source = dir_a } }, active = "a/only" })

		local key = tracker._set_key({ id = "03.1" })
		is_true(key:find("03.1", 1, true) ~= nil, "key mentions the set id: " .. key)
		is_true(key:find("only", 1, true) ~= nil, "key mentions the session: " .. key)
		is_true(key:find("a", 1, true) ~= nil, "key mentions the program: " .. key)
	end)
end)

h.summary()
