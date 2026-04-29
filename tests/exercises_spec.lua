local h = require("harness")
local describe, it, eq, is_true = h.describe, h.it, h.eq, h.is_true

local sources = require("coach.sources")
local sets = require("coach.sets")
sets._set_state_file(vim.fn.tempname() .. "_coach_state.json")
sets.configure({ active = "neovim-manual/01-first-steps" })

local exercises = require("coach.exercises")

describe("exercises (runtime)", function()
	describe("count", function()
		it("reflects the active volume's chapter count", function()
			is_true(exercises.count() > 0, "should have at least one chapter")
		end)
	end)

	describe("get", function()
		it("returns the first chapter of the first builtin volume", function()
			local e = exercises.get(1)
			is_true(e ~= nil, "first chapter should exist")
			if not e then
				return
			end
			eq("02.2", e.id)
			eq("Inserting Text", e.title)
		end)

		it("returns the last chapter", function()
			local e = exercises.get(exercises.count())
			is_true(e ~= nil, "last chapter should exist")
		end)

		it("returns nil for out of bounds", function()
			h.is_nil(exercises.get(0))
			h.is_nil(exercises.get(exercises.count() + 1))
			h.is_nil(exercises.get(-1))
		end)
	end)
end)

describe("builtin volumes", function()
	local volumes = sources.load({ name = "neovim-manual" })

	it("exposes more than one volume", function()
		is_true(#volumes > 1, "should have multiple volumes")
	end)

	local seen_ids = {}
	for _, v in ipairs(volumes) do
		describe("volume " .. v.name, function()
			it("has chapters", function()
				is_true(#v.chapters > 0)
			end)
			for _, ch in ipairs(v.chapters) do
				it("chapter " .. ch.id .. " is structurally valid", function()
					is_true(type(ch.id) == "string" and #ch.id > 0)
					is_true(type(ch.title) == "string" and #ch.title > 0)
					is_true(type(ch.help_tag) == "string")
					is_true(type(ch.actions) == "table" and #ch.actions > 0)
					for _, a in ipairs(ch.actions) do
						is_true(type(a.action) == "string" and #a.action > 0)
						is_true(type(a.display) == "string" and #a.display > 0)
						is_true(type(a.desc) == "string" and #a.desc > 0)
					end
				end)
			end
		end)
	end

	it("chapter IDs are globally unique across volumes", function()
		for _, v in ipairs(volumes) do
			for _, ch in ipairs(v.chapters) do
				is_true(not seen_ids[ch.id], "duplicate chapter id: " .. ch.id)
				seen_ids[ch.id] = true
			end
		end
	end)
end)

h.summary()
