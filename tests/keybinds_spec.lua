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
      vim.keymap.set("n", "L", function() vim.cmd("bnext") end, { desc = "Next Buffer" })
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
    it("returns empty table when no actions are shadowed", function()
      local kb = fresh_keybinds()
      local exercise = {
        id = "test", title = "Test",
        actions = {
          { action = "h", display = "h", desc = "left" },
          { action = "j", display = "j", desc = "down" },
        },
      }
      local shadowed = kb.get_shadowed(exercise)
      eq(0, vim.tbl_count(shadowed))
    end)

    it("identifies shadowed actions", function()
      vim.keymap.set("n", "H", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
      local kb = fresh_keybinds()
      local exercise = {
        id = "test", title = "Test",
        actions = {
          { action = "H", display = "H", desc = "top of screen" },
          { action = "j", display = "j", desc = "down" },
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
        id = "test", title = "Test",
        actions = { { action = "H", display = "H", desc = "top" } },
      }
      local shadowed = kb.get_shadowed(exercise)
      eq("Prev Buffer", shadowed["H"])
      vim.keymap.del("n", "H")
    end)

    it("returns empty for exercise with no actions", function()
      local kb = fresh_keybinds()
      local exercise = { id = "x", title = "x", actions = {} }
      local shadowed = kb.get_shadowed(exercise)
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
        actions = { { action = "h", display = "h", desc = "left" } },
      }
      local alts = kb.get_alternatives(exercise)
      eq(0, vim.tbl_count(alts))
    end)

    it("detects wincmd-style alternative", function()
      vim.keymap.set("n", "<C-h>", "<cmd>wincmd h<cr>", {})
      local kb = fresh_keybinds()
      local exercise = {
        actions = { { action = "<C-w>h", display = "Ctrl-W h", desc = "Window left" } },
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
        actions = { { action = "<C-w>j", display = "Ctrl-W j", desc = "Window down" } },
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
        actions = { { action = "<C-w>h", display = "Ctrl-W h", desc = "Window left" } },
      }
      local alts = kb.get_alternatives(exercise)
      eq(2, #alts["<C-w>h"])
      vim.keymap.del("n", "<C-h>")
      vim.keymap.del("n", "gh")
    end)

    it("does not count exercise action itself as alternative", function()
      local kb = fresh_keybinds()
      local exercise = {
        actions = { { action = "<C-w>h", display = "Ctrl-W h", desc = "Window left" } },
      }
      local alts = kb.get_alternatives(exercise)
      eq(0, vim.tbl_count(alts))
    end)

    it("detects tab navigation alternative", function()
      vim.keymap.set("n", "tn", "<cmd>tabnext<cr>", {})
      local kb = fresh_keybinds()
      local exercise = {
        actions = { { action = "gt", display = "gt", desc = "Next tab" } },
      }
      local alts = kb.get_alternatives(exercise)
      is_true(alts["gt"] ~= nil)
      vim.keymap.del("n", "tn")
    end)
  end)

end)

h.summary()
