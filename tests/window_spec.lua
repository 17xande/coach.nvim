local h = require("harness")
local describe, it, eq, is_true, is_false = h.describe, h.it, h.eq, h.is_true, h.is_false

local window = require("coach.window")

local sample_exercise = {
  id = "02.3",
  title = "Moving Around",
  help_tag = "02.3",
  actions = {
    { action = "h", display = "h", desc = "Move left" },
    { action = "j", display = "j", desc = "Move down" },
  },
}

local sample_exercise_no_help = {
  id = "99.1",
  title = "No Help Tag",
  actions = {
    { action = "x", display = "x", desc = "Test" },
  },
}

describe("window", function()

  describe("open and close", function()
    it("is not open initially", function()
      is_false(window.is_open())
    end)

    it("opens a floating window", function()
      window.open()
      is_true(window.is_open())
      window.close()
    end)

    it("close makes it not open", function()
      window.open()
      is_true(window.is_open())
      window.close()
      is_false(window.is_open())
    end)

    it("double open is safe", function()
      window.open()
      window.open()
      is_true(window.is_open())
      window.close()
    end)

    it("double close is safe", function()
      window.close()
      window.close()
      is_false(window.is_open())
    end)
  end)

  describe("toggle", function()
    it("opens when closed", function()
      window.close()
      local opened = window.toggle()
      is_true(opened)
      is_true(window.is_open())
      window.close()
    end)

    it("closes when open", function()
      window.open()
      local opened = window.toggle()
      is_false(opened)
      is_false(window.is_open())
    end)
  end)

  describe("render", function()
    it("renders without error on empty counts", function()
      window.open()
      window.render(sample_exercise, {}, 20, "<leader>kn")
      is_true(window.is_open())
      window.close()
    end)

    it("renders with partial counts", function()
      window.open()
      window.render(sample_exercise, { h = 5, j = 10 }, 20, "<leader>kn")
      is_true(window.is_open())
      window.close()
    end)

    it("renders completed exercise", function()
      window.open()
      window.render(sample_exercise, { h = 20, j = 20 }, 20, "<leader>kn")
      is_true(window.is_open())
      window.close()
    end)

    it("renders exercise without help_tag", function()
      window.open()
      window.render(sample_exercise_no_help, {}, 20, "<leader>kn")
      is_true(window.is_open())
      window.close()
    end)

    it("does not crash when window is closed", function()
      window.close()
      -- should silently do nothing
      window.render(sample_exercise, {}, 20, "<leader>kn")
      is_false(window.is_open())
    end)

    it("renders counts clamped to required_reps", function()
      window.open()
      -- count exceeds required_reps, should not crash
      window.render(sample_exercise, { h = 999, j = 999 }, 20, "<leader>kn")
      is_true(window.is_open())
      window.close()
    end)
  end)

  describe("set_message", function()
    it("does not crash", function()
      window.open()
      window.set_message("Test message")
      window.render(sample_exercise, {}, 20, "<leader>kn")
      is_true(window.is_open())
      window.close()
    end)
  end)

end)

h.summary()
