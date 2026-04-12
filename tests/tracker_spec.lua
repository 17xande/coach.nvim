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

h.summary()
