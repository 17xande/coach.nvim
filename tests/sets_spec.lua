local h = require("harness")
local describe, it, eq, is_true = h.describe, h.it, h.eq, h.is_true

local sources = require("coach.sources")
local programs = require("coach.programs")
programs._set_state_file(vim.fn.tempname() .. "_coach_state.json")
programs.configure({ active = "user-manual/01-first-steps" })

local sets = require("coach.sets")

describe("sets (runtime)", function()
	describe("count", function()
		it("reflects the active session's set count", function()
			is_true(sets.count() > 0, "should have at least one set")
		end)
	end)

	describe("get", function()
		it("returns the first set of the first builtin session", function()
			local s = sets.get(1)
			is_true(s ~= nil, "first set should exist")
			if not s then
				return
			end
			eq("02.2", s.id)
			eq("Inserting Text", s.title)
		end)

		it("returns the last set", function()
			local s = sets.get(sets.count())
			is_true(s ~= nil, "last set should exist")
		end)

		it("returns nil for out of bounds", function()
			h.is_nil(sets.get(0))
			h.is_nil(sets.get(sets.count() + 1))
			h.is_nil(sets.get(-1))
		end)
	end)
end)

describe("builtin sessions", function()
	local sessions = sources.load({ name = "user-manual" })

	it("exposes more than one session", function()
		is_true(#sessions > 1, "should have multiple sessions")
	end)

	local seen_ids = {}
	for _, sess in ipairs(sessions) do
		describe("session " .. sess.name, function()
			it("has sets", function()
				is_true(#sess.sets > 0)
			end)
			for _, s in ipairs(sess.sets) do
				it("set " .. s.id .. " is structurally valid", function()
					is_true(type(s.id) == "string" and #s.id > 0)
					is_true(type(s.title) == "string" and #s.title > 0)
					is_true(type(s.help_tag) == "string")
					is_true(type(s.exercises) == "table" and #s.exercises > 0)
					for _, e in ipairs(s.exercises) do
						is_true(type(e.exercise) == "string" and #e.exercise > 0)
						is_true(type(e.display) == "string" and #e.display > 0)
						is_true(type(e.desc) == "string" and #e.desc > 0)
					end
				end)
			end
		end)
	end

	it("set IDs are globally unique across sessions", function()
		for _, sess in ipairs(sessions) do
			for _, s in ipairs(sess.sets) do
				is_true(not seen_ids[s.id], "duplicate set id: " .. s.id)
				seen_ids[s.id] = true
			end
		end
	end)
end)

h.summary()
