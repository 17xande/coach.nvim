-- End-to-end spec: real keys, real Neovim, all the way to a counted rep
-- Run: nvim --headless -u tests/minimal_init.lua -c "luafile tests/e2e_spec.lua"
--
-- Every other spec in this repo tests a seam. This one tests the *chain*: a child
-- Neovim with both plugins loaded, coaching started, real keys typed through
-- `nvim_input`, and the assertion is that `progress.get_counts()` went up.
--
--   keypress -> CmdAtom -> track-action atom.lua -> render.lua -> tracker
--            -> coach.tracker -> resolve_match_action -> progress
--
-- Worth its own file because every link in that chain has its own fence and the
-- chain still had a bug: the `<Home>` count and five uncreditable exercises were
-- both found by driving content rather than by testing a seam. A unit fence cannot
-- catch a *missing* link.
--
-- Needs a sibling `../track-action.nvim` checkout and skips itself without one, so
-- the suite still passes for someone who has only this plugin. Check the output for
-- a "skipping" line before trusting a green run here.

package.path = "tests/?.lua;" .. package.path
local h = require("harness")
local describe, it, eq = h.describe, h.it, h.eq

local TRACK_ACTION = vim.fn.fnamemodify(vim.fn.getcwd(), ":h") .. "/track-action.nvim"
local RPC = TRACK_ACTION .. "/tests/rpc.lua"

if vim.fn.filereadable(RPC) ~= 1 then
	print("e2e_spec: no track-action.nvim checkout at " .. TRACK_ACTION .. ", skipping")
	h.summary()
	return
end

-- The harness lives in track-action, because the fact it encodes -- that an
-- in-process `nvim_feedkeys` publishes no atoms -- is a fact about that plugin's
-- input source. Loaded by path rather than copied, so the two cannot drift.
local rpc = dofile(RPC)

--- A child Neovim with both plugins loaded and coaching started.
---
--- Progress and stats go to scratch paths: a spec that wrote to the real ones would
--- count its own drills against the user's history.
local function coaching_child()
	local child = rpc.start({ rtp = { TRACK_ACTION, vim.fn.getcwd() } })
	child:lua(
		[[
    local stats, progress_dir = ...
    vim.g.mapleader = ","
    require("track-action").setup({ stats_file = stats })
    require("coach").setup({
      required_reps = 3,
      progress_dir = progress_dir,
      active = "user-manual/02-moving-around",
    })
    require("coach").start()
  ]],
		{ vim.fn.tempname() .. "-e2e-stats.json", vim.fn.tempname() .. "-e2e-progress" }
	)
	return child
end

--- Move the child to the set with this id, in the named session, and give it a
--- buffer with something for every motion to reach.
local function goto_set(child, session, set_id)
	return child:lua(
		[[
    local session, set_id = ...
    require("coach").switch_session("user-manual/" .. session)
    local sets, progress = require("coach.sets"), require("coach.progress")
    for i = 1, sets.count() do
      if sets.get(i).id == set_id then progress.go_to(i) end
    end
    vim.cmd("enew!")
    vim.bo.swapfile = false
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {
      "alpha (beta) gamma delta", "one two three four", "five six seven", "eight nine ten",
    })
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    vim.bo.modified = false
    return sets.get(progress.get_set_index()).id
  ]],
		{ session, set_id }
	)
end

local function counts(child)
	return child:lua("return require('coach.progress').get_counts()")
end

describe("a rep counted from a real keypress", function()
	local child = coaching_child()

	it("starts coaching at all", function()
		eq(true, child:lua("return require('coach.progress').is_coaching_active()"))
	end)

	it("loads the session's sets", function()
		eq(true, child:lua("return require('coach.sets').count()") > 0)
	end)

	it("counts the motions of a word-movement set", function()
		eq("03.1", goto_set(child, "02-moving-around", "03.1"))
		-- Interleaved, not repeated: the anti-spam cooldown refuses the same action
		-- twice within the last three, which is itself part of the chain.
		for _ = 1, 3 do
			child:press("w")
			child:press("b")
			child:press("e")
			child:press("ge")
		end
		local got = counts(child)
		eq(3, got.w)
		eq(3, got.b)
		eq(3, got.e)
		eq(3, got.ge, "ge was the g-prefix bug that took a pending-keys replay to fix")
	end)

	it("completes the set once every exercise is filled", function()
		eq(true, child:lua("return require('coach.progress').is_set_complete()"))
	end)

	it("counts a counted motion as the counted exercise, not the bare one", function()
		eq("03.1c", goto_set(child, "02-moving-around", "03.1c"))
		child:press("3w")
		child:press("3b")
		local got = counts(child)
		eq(1, got["[count]w"])
		eq(1, got["[count]b"])
		eq(nil, got.w, "a counted press must not credit the uncounted drill")
	end)

	it("counts r{char} whatever character is typed", function()
		-- Dead before the rewrite: the parser never emitted it, so the row could not
		-- be filled and the set blocked forever.
		--
		-- Three other actions between the two `r`s, because the cooldown ring holds
		-- the last *three* -- `rx w ry` credits once, which is the cooldown working
		-- and is asserted below.
		eq("04.2", goto_set(child, "03-making-changes", "04.2"))
		child:press("rx")
		child:press("w")
		child:press("b")
		child:press("e")
		child:press("ry")
		eq(2, counts(child)["r{char}"], "both characters credit the one exercise")
	end)

	it("refuses the same exercise twice inside the cooldown window", function()
		-- Asserted end-to-end because the ring lives in coach and the action naming
		-- lives in track-action: only the whole chain shows that `rz` and `rq` are
		-- the *same* row as far as the cooldown is concerned, which is the point of
		-- the placeholder.
		--
		-- Three other actions first, to clear `r{char}` out of a ring that holds three.
		child:press("w")
		child:press("b")
		child:press("e")
		local before = counts(child)["r{char}"]
		child:press("rz")
		eq(before + 1, counts(child)["r{char}"], "a clear ring credits it")
		child:press("rq")
		eq(before + 1, counts(child)["r{char}"], "a different char, but the same row, so refused")
	end)

	it("counts a typed ex command under Vim's own name for it", function()
		eq("03.8", goto_set(child, "02-moving-around", "03.8"))
		child:press(":nohlsearch<CR>")
		eq(1, counts(child)["ex:nohlsearch"])
	end)

	it("counts an abbreviated ex command as the same exercise", function()
		-- Separated from the previous `:nohlsearch` by three other actions, or the
		-- cooldown refuses it -- which is itself the proof that both spellings
		-- resolve to one action, since the ring matches on the action string.
		child:press("w")
		child:press("b")
		child:press("e")
		child:press(":noh<CR>")
		eq(2, counts(child)["ex:nohlsearch"], ":noh and :nohlsearch are one command")
	end)

	it("counts a <leader> mapping as the command it performs", function()
		-- No resolution anywhere: Neovim reports the command the mapping ran.
		eq("03.1c", goto_set(child, "02-moving-around", "03.1c"))
		child:lua([[vim.keymap.set("n", ",W", "5w")]])
		-- This set already has a `[count]w` from the counted-motion case above, and
		-- progress persists across a `go_to` -- so the assertion is on the increment.
		local before = counts(child)["[count]w"] or 0
		child:press("b")
		child:press("e")
		child:press(",W")
		eq(before + 1, counts(child)["[count]w"])
	end)

	it("learns a mapping as an alternative once it has been pressed", function()
		-- The replacement for the static scan, and the reason it needs no
		-- interpretation: Neovim reports the command the mapping ran *and* the keys
		-- that ran it, so pressing it once is what teaches the window.
		eq("03.1", goto_set(child, "02-moving-around", "03.1"))
		child:lua([[
      require("coach.alternatives").clear()
      vim.keymap.set("n", ",e", "e")
    ]])
		eq(0, #child:lua([[return require("coach.alternatives").for_exercise("e")]]), "nothing learned yet")

		child:press(",e")
		local learned = child:lua([[return require("coach.alternatives").for_exercise("e")]])
		eq(1, #learned)
		-- Displayed with the leader normalized, since mapleader is "," here.
		eq("<leader>e", learned[1])
	end)

	it("learns a `:`-style mapping as the ex command it runs", function()
		-- A `:` right-hand side goes through the cmdline, so the ex command is
		-- reported in full and the mapping is credited and learned.
		eq("03.8", goto_set(child, "02-moving-around", "03.8"))
		child:lua([[
      require("coach.alternatives").clear()
      vim.keymap.set("n", ",h", ":nohlsearch<CR>")
    ]])
		child:press(",h")
		local learned = child:lua([[return require("coach.alternatives").for_exercise("ex:nohlsearch")]])
		eq(1, #learned)
		eq("<leader>h", learned[1])
	end)

	it("cannot credit a <Cmd> mapping, which is the recommended spelling", function()
		-- **The limitation most likely to bite a real config.** `:help <Cmd>`
		-- recommends `<Cmd>` over `:` precisely because it avoids the cmdline
		-- events -- and avoiding them is what loses the command. A
		-- `<Cmd>nohlsearch<CR>` mapping reports only that *a mapping* ran, with no
		-- command and no text, so there is nothing to credit or to learn.
		--
		-- Asserted rather than left as a surprise. The workaround is the older `:`
		-- spelling, as in the case above.
		eq("03.8", goto_set(child, "02-moving-around", "03.8"))
		child:lua([[
      require("coach.alternatives").clear()
      vim.keymap.set("n", ",H", "<Cmd>nohlsearch<CR>")
    ]])
		child:press(",H")
		eq(0, #child:lua([[return require("coach.alternatives").for_exercise("ex:nohlsearch")]]))
	end)

	it("cannot learn a Lua-callback mapping that runs :normal", function()
		-- **The limitation, asserted so it is not rediscovered as a bug.** A callback
		-- reports `type="mapping"` with an empty `keys` and no `cmd` at all: Neovim
		-- says a mapping ran and says nothing about what it did, because `:normal`
		-- is programmatic input and publishes no atom of its own.
		--
		-- So the action rendered is the lhs itself. A set drilling `b` is not
		-- credited, and there is nothing to attach as an alternative. The old
		-- parser-based scan could not reach these either -- its rhs was not keys --
		-- so nothing regressed, but neither is this fixed.
		eq("03.1", goto_set(child, "02-moving-around", "03.1"))
		child:lua([[
      require("coach.alternatives").clear()
      vim.keymap.set("n", ",B", function() vim.cmd("normal! b") end)
    ]])
		child:press(",B")
		eq(0, #child:lua([[return require("coach.alternatives").for_exercise("b")]]))
	end)

	it("shows a learned mapping in the window beside the default keys", function()
		eq("03.1", goto_set(child, "02-moving-around", "03.1"))
		child:lua([[
      require("coach.alternatives").clear()
      vim.keymap.set("n", ",w", "w")
    ]])
		child:press(",w")
		local text = child:lua([[
      local window, sets, progress = require("coach.window"), require("coach.sets"), require("coach.progress")
      window.open()
      local s = sets.get(progress.get_set_index())
      window.render(s, progress.get_counts(), 3, "<leader>kn",
        require("coach.keybinds").get_shadowed(s), require("coach.keybinds").get_alternatives(s))
      local lines = vim.api.nvim_buf_get_lines(window._buf(), 0, -1, false)
      window.close()
      return table.concat(lines, "\n")
    ]])
		eq(true, text:find("<leader>w", 1, true) ~= nil, text)
	end)

	it("counts % even though matchit turns it into an ex call", function()
		-- Creditable only through the keys pressed; the atom names the ex call. This
		-- is also the shadow gap that used to be documented as unfixable.
		eq("03.4", goto_set(child, "02-moving-around", "03.4"))
		child:lua([[vim.api.nvim_win_set_cursor(0, { 1, 6 })]])
		child:press("%")
		eq(1, counts(child)["%"])
	end)

	it("counts an insert session when it ends, not while typing", function()
		eq("02.2", goto_set(child, "01-first-steps", "02.2"))
		eq(0, #child:press("i"))
		child:press("abc")
		eq(nil, counts(child).i, "nothing is credited while still inserting")
		child:press("<Esc>")
		eq(1, counts(child).i, "the rep lands on <Esc>")
	end)

	it("does not count an unsupported exercise, and does not block on it", function()
		-- 02.4 drills `x`, which Neovim reports as `dl`. The row can never fill, so
		-- the set has to complete without it or `:CoachNext` is stuck forever.
		eq("02.4", goto_set(child, "01-first-steps", "02.4"))
		local before = counts(child)
		child:press("x")
		child:press("w")
		child:press("x")
		eq(before.x, counts(child).x, "`x` reports as `dl` and cannot be credited")

		local complete = child:lua([[
      local sets, progress = require("coach.sets"), require("coach.progress")
      local set = sets.get(progress.get_set_index())
      for _, e in ipairs(set.exercises) do
        if not require("coach.unsupported").is(e.exercise) then
          for _ = 1, 10 do progress.increment(e.exercise) end
        end
      end
      return progress.is_set_complete()
    ]])
		eq(true, complete, "a set holding `x` must still be completable")
	end)

	child:lua("for _, b in ipairs(vim.api.nvim_list_bufs()) do pcall(function() vim.bo[b].modified = false end) end")
	child:stop()
end)

h.summary()
