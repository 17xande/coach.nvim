local h = require("harness")
local describe, it, eq, is_true = h.describe, h.it, h.eq, h.is_true

local exercises = require("coach.exercises")

describe("exercises", function()

  describe("count", function()
    it("returns a positive number", function()
      local c = exercises.count()
      is_true(c > 0, "should have at least one exercise")
    end)
  end)

  describe("get", function()
    it("returns first exercise", function()
      local e = exercises.get(1)
      is_true(e ~= nil, "first exercise should exist")
      if not e then return end
      eq("02.2", e.id)
      eq("Inserting Text", e.title)
    end)

    it("returns last exercise", function()
      local e = exercises.get(exercises.count())
      is_true(e ~= nil, "last exercise should exist")
    end)

    it("returns nil for out of bounds", function()
      h.is_nil(exercises.get(0))
      h.is_nil(exercises.get(exercises.count() + 1))
      h.is_nil(exercises.get(-1))
    end)
  end)

  describe("exercise structure", function()
    for i = 1, exercises.count() do
      local e = exercises.get(i)
      if not e then break end
      it("exercise " .. e.id .. " has required fields", function()
        is_true(type(e.id) == "string", "id should be string")
        is_true(type(e.title) == "string", "title should be string")
        is_true(type(e.help_tag) == "string", "help_tag should be string")
        is_true(type(e.actions) == "table", "actions should be table")
        is_true(#e.actions > 0, "actions should not be empty")
      end)
    end
  end)

  describe("action structure", function()
    for i = 1, exercises.count() do
      local e = exercises.get(i)
      if not e then break end
      for _, a in ipairs(e.actions) do
        it(e.id .. " action '" .. a.action .. "' has required fields", function()
          is_true(type(a.action) == "string", "action should be string")
          is_true(type(a.display) == "string", "display should be string")
          is_true(type(a.desc) == "string", "desc should be string")
          is_true(#a.action > 0, "action should not be empty")
          is_true(#a.display > 0, "display should not be empty")
          is_true(#a.desc > 0, "desc should not be empty")
        end)
      end
    end
  end)

  describe("unique IDs", function()
    it("all exercise IDs are unique", function()
      local seen = {}
      for i = 1, exercises.count() do
        local e = exercises.get(i)
        if not e then break end
        is_true(not seen[e.id], "duplicate ID: " .. e.id)
        seen[e.id] = true
      end
    end)
  end)

end)

h.summary()
