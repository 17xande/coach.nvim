local h = require("harness")
local describe, it, eq, is_true, is_false = h.describe, h.it, h.eq, h.is_true, h.is_false

local function fresh_keybinds()
	package.loaded["coach.keybinds"] = nil
	return require("coach.keybinds")
end

describe("keybinds", function()
	describe("is_shadowed", function()
		it("returns false for unmapped action", function()
			local kb = fresh_keybinds()
			is_false(kb.is_shadowed("h"))
		end)

		it("returns false when rhs equals the action (passthrough)", function()
			vim.keymap.set("n", "J", "J", {})
			local kb = fresh_keybinds()
			local is_sh = kb.is_shadowed("J")
			is_false(is_sh)
			vim.keymap.del("n", "J")
		end)

		it("returns false for count-expr wrapped motion", function()
			vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
			local kb = fresh_keybinds()
			local is_sh = kb.is_shadowed("j")
			is_false(is_sh)
			vim.keymap.del("n", "j")
		end)

		it("returns true and desc for cmd-style remap", function()
			vim.keymap.set("n", "H", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
			local kb = fresh_keybinds()
			local is_sh, desc = kb.is_shadowed("H")
			is_true(is_sh)
			eq("Prev Buffer", desc)
			vim.keymap.del("n", "H")
		end)

		it("returns true for lua callback remap", function()
			vim.keymap.set("n", "L", function()
				vim.cmd("bnext")
			end, { desc = "Next Buffer" })
			local kb = fresh_keybinds()
			local is_sh = kb.is_shadowed("L")
			is_true(is_sh)
			vim.keymap.del("n", "L")
		end)

		it("returns false for unmapped multi-char action", function()
			local kb = fresh_keybinds()
			-- <C-w>h is not remapped in headless nvim
			is_false(kb.is_shadowed("<C-w>h"))
		end)

		it("returns true for remapped multi-char action", function()
			vim.keymap.set("n", "<C-w>h", "<cmd>echo 'nope'<cr>", { desc = "Intercepted" })
			local kb = fresh_keybinds()
			local is_sh, desc = kb.is_shadowed("<C-w>h")
			is_true(is_sh)
			eq("Intercepted", desc)
			vim.keymap.del("n", "<C-w>h")
		end)
	end)

	describe("get_shadowed", function()
		it("returns empty table when no exercises are shadowed", function()
			local kb = fresh_keybinds()
			local exercise = {
				id = "test",
				title = "Test",
				exercises = {
					{ exercise = "h", display = "h", desc = "left" },
					{ exercise = "j", display = "j", desc = "down" },
				},
			}
			local shadowed = kb.get_shadowed(exercise)
			eq(0, vim.tbl_count(shadowed))
		end)

		it("identifies shadowed exercises", function()
			vim.keymap.set("n", "H", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
			local kb = fresh_keybinds()
			local exercise = {
				id = "test",
				title = "Test",
				exercises = {
					{ exercise = "H", display = "H", desc = "top of screen" },
					{ exercise = "j", display = "j", desc = "down" },
				},
			}
			local shadowed = kb.get_shadowed(exercise)
			is_true(shadowed["H"] ~= nil)
			is_false(shadowed["j"] ~= nil)
			vim.keymap.del("n", "H")
		end)

		it("stores description when available", function()
			vim.keymap.set("n", "H", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
			local kb = fresh_keybinds()
			local exercise = {
				id = "test",
				title = "Test",
				exercises = { { exercise = "H", display = "H", desc = "top" } },
			}
			local shadowed = kb.get_shadowed(exercise)
			eq("Prev Buffer", shadowed["H"])
			vim.keymap.del("n", "H")
		end)

		it("returns empty for set with no exercises", function()
			local kb = fresh_keybinds()
			local set = { id = "x", title = "x", exercises = {} }
			local shadowed = kb.get_shadowed(set)
			eq(0, vim.tbl_count(shadowed))
		end)
	end)

	describe("format_key_display", function()
		it("converts ctrl notation to readable form", function()
			local kb = fresh_keybinds()
			eq("Ctrl-H", kb.format_key_display("<C-H>"))
		end)

		it("leaves plain keys unchanged", function()
			local kb = fresh_keybinds()
			eq("gh", kb.format_key_display("gh"))
		end)

		it("normalizes leader prefix", function()
			local old_leader = vim.g.mapleader
			vim.g.mapleader = " "
			local kb = fresh_keybinds()
			eq("<leader>sv", kb.format_key_display(" sv"))
			vim.g.mapleader = old_leader
		end)
	end)

	describe("get_alternatives", function()
		it("returns empty when no alternatives exist", function()
			local kb = fresh_keybinds()
			local exercise = {
				exercises = { { exercise = "h", display = "h", desc = "left" } },
			}
			local alts = kb.get_alternatives(exercise)
			eq(0, vim.tbl_count(alts))
		end)

		it("detects wincmd-style alternative", function()
			vim.keymap.set("n", "<C-h>", "<cmd>wincmd h<cr>", {})
			local kb = fresh_keybinds()
			local exercise = {
				exercises = { { exercise = "<C-w>h", display = "Ctrl-W h", desc = "Window left" } },
			}
			local alts = kb.get_alternatives(exercise)
			is_true(alts["<C-w>h"] ~= nil)
			eq(1, #alts["<C-w>h"])
			eq("Ctrl-H", alts["<C-w>h"][1])
			vim.keymap.del("n", "<C-h>")
		end)

		it("detects direct key-sequence alternative", function()
			vim.keymap.set("n", "<C-j>", "<C-w>j", {})
			local kb = fresh_keybinds()
			local exercise = {
				exercises = { { exercise = "<C-w>j", display = "Ctrl-W j", desc = "Window down" } },
			}
			local alts = kb.get_alternatives(exercise)
			is_true(alts["<C-w>j"] ~= nil)
			eq(1, #alts["<C-w>j"])
			vim.keymap.del("n", "<C-j>")
		end)

		it("detects multiple alternatives for same action", function()
			vim.keymap.set("n", "<C-h>", "<cmd>wincmd h<cr>", {})
			vim.keymap.set("n", "gh", "<cmd>wincmd h<cr>", {})
			local kb = fresh_keybinds()
			local exercise = {
				exercises = { { exercise = "<C-w>h", display = "Ctrl-W h", desc = "Window left" } },
			}
			local alts = kb.get_alternatives(exercise)
			eq(2, #alts["<C-w>h"])
			vim.keymap.del("n", "<C-h>")
			vim.keymap.del("n", "gh")
		end)

		it("does not count exercise action itself as alternative", function()
			local kb = fresh_keybinds()
			local exercise = {
				exercises = { { exercise = "<C-w>h", display = "Ctrl-W h", desc = "Window left" } },
			}
			local alts = kb.get_alternatives(exercise)
			eq(0, vim.tbl_count(alts))
		end)

		it("detects tab navigation alternative", function()
			vim.keymap.set("n", "tn", "<cmd>tabnext<cr>", {})
			local kb = fresh_keybinds()
			local exercise = {
				exercises = { { exercise = "gt", display = "gt", desc = "Next tab" } },
			}
			local alts = kb.get_alternatives(exercise)
			is_true(alts["gt"] ~= nil)
			vim.keymap.del("n", "tn")
		end)
	end)

	-- Exercises carry the decorations track-action puts in an action string:
	-- `[count]w`, `f{char}`. Neither is a key anyone can press, so a lookup that
	-- passes one to maparg() finds nothing and silently reports "not shadowed" --
	-- leaving the exercise demanding reps for a key the user has remapped away.
	local has_track_action = pcall(require, "track-action.commands")
	if not has_track_action then
		print("keybinds_spec: track-action.nvim not found, skipping the decorated-exercise tests")
	end

	describe("decorated exercises", has_track_action and function()
		describe("is_shadowed strips the decoration first", function()
			it("a remapped f shadows f{char}", function()
				vim.keymap.set("n", "f", "<cmd>echo 'flash'<cr>", { desc = "Flash" })
				local kb = fresh_keybinds()
				local is_sh, desc = kb.is_shadowed("f{char}")
				is_true(is_sh)
				eq("Flash", desc)
				vim.keymap.del("n", "f")
			end)

			it("a remapped w shadows both w and [count]w", function()
				vim.keymap.set("n", "w", "<cmd>echo 'nope'<cr>", { desc = "Hijacked" })
				local kb = fresh_keybinds()
				is_true(kb.is_shadowed("w"))
				is_true(kb.is_shadowed("[count]w"))
				vim.keymap.del("n", "w")
			end)

			it("an unmapped decorated exercise is not shadowed", function()
				local kb = fresh_keybinds()
				is_false(kb.is_shadowed("f{char}"))
				is_false(kb.is_shadowed("[count]e"))
				is_false(kb.is_shadowed("m{mark}"))
			end)

			it("a multi-key decorated exercise strips to its whole key sequence", function()
				vim.keymap.set("n", "dw", "<cmd>echo 'nope'<cr>", { desc = "Hijacked" })
				local kb = fresh_keybinds()
				is_true(kb.is_shadowed("[count]dw"))
				vim.keymap.del("n", "dw")
			end)

			it("a mapping on a prefix of the keys is not detected", function()
				-- Known gap, unchanged by this: remapping `d` does stop `dw` working,
				-- but is_shadowed only asks about the whole sequence. It applies to
				-- every operator exercise, decorated or not, so it belongs with the
				-- other shadow-detection work rather than here.
				vim.keymap.set("n", "d", "<cmd>echo 'nope'<cr>", { desc = "Hijacked" })
				local kb = fresh_keybinds()
				is_false(kb.is_shadowed("[count]dw"))
				is_false(kb.is_shadowed("dw"))
				vim.keymap.del("n", "d")
			end)

			it("the count-expr escape hatch applies to [count]j", function()
				-- The most commonly remapped counted motion, and the gate used to be
				-- `#exercise == 1`, so it could never fire for "[count]j".
				vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
				local kb = fresh_keybinds()
				is_false(kb.is_shadowed("j"))
				is_false(kb.is_shadowed("[count]j"))
				vim.keymap.del("n", "j")
			end)
		end)

		describe("get_alternatives resolves the mapping's action", function()
			-- A mapping to a *decorated* exercise -- `<leader>W` -> `5w` for
			-- `[count]w`, `<leader>F` -> `fx` for `f{char}` -- used to be recognised
			-- here, by running the right-hand side through track-action's parser and
			-- comparing the action it produced. Comparing text never worked, because
			-- one side is keys and the other an action string.
			--
			-- There is no parser now, and no way to ask what a key sequence would do
			-- without pressing it, so these are asserted *not* to resolve. They are
			-- pinned rather than deleted because the loss is temporary and the fix is
			-- better than what it replaces: a mapping's `lhs` arrives on every atom it
			-- produces, so the alternative is learned the first time the user presses
			-- it -- which also covers a Lua-callback mapping, which the parser could
			-- never reach. When that lands, these two become positive assertions again.
			it("a map to 5w is not resolved to [count]w without the parser", function()
				vim.keymap.set("n", "<leader>W", "5w", {})
				local kb = fresh_keybinds()
				local alts = kb.get_alternatives({
					exercises = {
						{ exercise = "w", display = "w", desc = "Word" },
						{ exercise = "[count]w", display = "[count]w", desc = "N words" },
					},
				})
				is_false(alts["[count]w"] ~= nil)
				is_false(alts["w"] ~= nil)
				vim.keymap.del("n", "<leader>W")
			end)

			it("a map to fx is not resolved to f{char} without the parser", function()
				vim.keymap.set("n", "<leader>F", "fx", {})
				local kb = fresh_keybinds()
				local alts = kb.get_alternatives({
					exercises = { { exercise = "f{char}", display = "f{char}", desc = "Find" } },
				})
				is_false(alts["f{char}"] ~= nil)
				vim.keymap.del("n", "<leader>F")
			end)

			it("a map to an exercise's own keys is still an alternative", function()
				-- The undecorated case needs no resolution at all: the right-hand side
				-- *is* the exercise's keys, so this is what still works and what the
				-- two cases above are measured against.
				vim.keymap.set("n", "<leader>h", "<C-w>h", {})
				local kb = fresh_keybinds()
				local alts = kb.get_alternatives({
					exercises = { { exercise = "<C-w>h", display = "<C-w>h", desc = "Window left" } },
				})
				is_true(alts["<C-w>h"] ~= nil, "a direct key mapping should still resolve")
				vim.keymap.del("n", "<leader>h")
			end)

			it("a <Plug> mapping is not an alternative for anything", function()
				vim.keymap.set("n", "<leader>P", "<Plug>SomePluginThing", {})
				local kb = fresh_keybinds()
				local alts = kb.get_alternatives({
					exercises = { { exercise = "w", display = "w", desc = "Word" } },
				})
				eq(0, vim.tbl_count(alts))
				vim.keymap.del("n", "<leader>P")
			end)

			it("an expr mapping is not an alternative either", function()
				-- Its rhs is an expression to evaluate, not keys to press.
				vim.keymap.set("n", "<leader>E", "'w'", { expr = true })
				local kb = fresh_keybinds()
				local alts = kb.get_alternatives({
					exercises = { { exercise = "w", display = "w", desc = "Word" } },
				})
				eq(0, vim.tbl_count(alts))
				vim.keymap.del("n", "<leader>E")
			end)
		end)

		-- coach used to keep its own 14-entry `ex_to_native` table. It now asks
		-- track-action's `mappings.native_for_ex`, which knows 28 commands and
		-- accepts a bang and arguments, so these cases work rather than being
		-- silently unrecognised.
		describe("ex commands resolved through track-action", function()
			--- Is `<leader>Q` mapped to `rhs` an alternative for `exercise`?
			local function is_alternative(rhs, exercise)
				vim.keymap.set("n", "<leader>Q", rhs, {})
				local kb = fresh_keybinds()
				local alts = kb.get_alternatives({
					exercises = { { exercise = exercise, display = exercise, desc = "x" } },
				})
				vim.keymap.del("n", "<leader>Q")
				return alts[exercise] ~= nil
			end

			it("recognises <cmd>vsplit<cr> as <C-w>v", function()
				is_true(is_alternative("<cmd>vsplit<cr>", "<C-w>v"))
			end)

			it("recognises a command coach's own table never had", function()
				is_true(is_alternative("<cmd>vnew<cr>", "<C-w>v"))
			end)

			it("recognises a wincmd coach's own table never had", function()
				is_true(is_alternative("<cmd>wincmd p<cr>", "<C-w>p"))
			end)

			it("recognises a command with an argument", function()
				is_true(is_alternative("<cmd>vsplit foo.txt<cr>", "<C-w>v"))
			end)

			it("recognises a command with a bang", function()
				is_true(is_alternative("<cmd>split!<cr>", "<C-w>s"))
			end)

			it("does not invent an equivalence for an unrelated command", function()
				is_false(is_alternative("<cmd>Telescope find_files<cr>", "<C-w>v"))
			end)
		end)
	end or function() end)
end)

h.summary()
