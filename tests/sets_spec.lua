local h = require("harness")
local describe, it, eq, is_true, is_false = h.describe, h.it, h.eq, h.is_true, h.is_false

local function fresh()
	package.loaded["coach.exercises"] = nil
	package.loaded["coach.sets"] = nil
	package.loaded["coach.sources"] = nil
	package.loaded["coach.builtin"] = nil
	package.loaded["coach.exercises_data"] = nil
	local sets = require("coach.sets")
	sets._set_state_file(vim.fn.tempname() .. "_coach_sets_state.json")
	return sets
end

--- Build a temp volume directory.
---@return string dir
local function make_dir(volumes)
	local dir = vim.fn.tempname() .. "_coach_vols"
	vim.fn.mkdir(dir, "p")
	for name, body in pairs(volumes) do
		local f = assert(io.open(dir .. "/" .. name .. ".lua", "w"))
		f:write(body)
		f:close()
	end
	return dir
end

describe("sets", function()
	describe("configure", function()
		it("always includes the builtin set", function()
			local sets = fresh()
			sets.configure({})
			local names = {}
			for _, s in ipairs(sets.list()) do
				table.insert(names, s.name)
			end
			eq("neovim-manual", names[1])
		end)

		it("picks the first volume of the first set by default", function()
			local sets = fresh()
			sets.configure({})
			local active = sets.get_active()
			is_true(active ~= nil)
			if not active then
				return
			end
			eq("neovim-manual", active.set)
			eq("01-first-steps", active.volume)
		end)

		it("honors active option as set/volume", function()
			local sets = fresh()
			sets.configure({ active = "neovim-manual/02-moving-around" })
			local active = sets.get_active()
			if not active then
				error("no active")
			end
			eq("02-moving-around", active.volume)
		end)

		it("swaps exercises.list on activation", function()
			local sets = fresh()
			local exercises = require("coach.exercises")
			eq(0, #exercises.list)
			sets.configure({ active = "neovim-manual/02-moving-around" })
			is_true(#exercises.list > 0)
			eq("03.1", exercises.list[1].id)
		end)

		it("loads a local-dir set", function()
			local dir = make_dir({
				["01-foo"] = "return { { id='f.1', title='F', actions={ { action='w', display='w', desc='d' } } } }",
				["02-bar"] = "return { { id='b.1', title='B', actions={ { action='e', display='e', desc='d' } } } }",
			})
			local sets = fresh()
			sets.configure({ sets = { { name = "custom", source = dir } } })
			local vols = sets.volumes("custom")
			eq(2, #vols)
			eq("01-foo", vols[1].name)
		end)
	end)

	describe("switch", function()
		it("changes the active volume and exercises.list", function()
			local sets = fresh()
			local exercises = require("coach.exercises")
			sets.configure({})

			local ok, err = sets.switch("neovim-manual", "02-moving-around")
			is_true(ok, err)
			eq("02-moving-around", sets.get_active().volume)
			eq("03.1", exercises.list[1].id)
		end)

		it("defaults to the first volume if name omitted", function()
			local sets = fresh()
			sets.configure({})
			sets.switch("neovim-manual", "02-moving-around")
			local ok = sets.switch("neovim-manual", nil)
			is_true(ok)
			eq("01-first-steps", sets.get_active().volume)
		end)

		it("returns an error for unknown set", function()
			local sets = fresh()
			sets.configure({})
			local ok, err = sets.switch("nope", nil)
			is_false(ok)
			is_true(type(err) == "string")
		end)

		it("returns an error for unknown volume", function()
			local sets = fresh()
			sets.configure({})
			local ok, err = sets.switch("neovim-manual", "does-not-exist")
			is_false(ok)
			is_true(type(err) == "string")
		end)

		it("fires the _on_switch hook", function()
			local sets = fresh()
			sets.configure({})
			local fired = nil
			sets._on_switch = function(s, v)
				fired = s .. "/" .. v
			end
			sets.switch("neovim-manual", "02-moving-around")
			eq("neovim-manual/02-moving-around", fired)
		end)
	end)

	describe("all_volume_pairs", function()
		it("lists pairs across sets", function()
			local sets = fresh()
			sets.configure({})
			local pairs_list = sets.all_volume_pairs()
			is_true(#pairs_list > 1)
			-- first pair should be the first builtin volume
			eq("neovim-manual", pairs_list[1].set)
			eq("01-first-steps", pairs_list[1].volume)
		end)
	end)

	describe("active persistence", function()
		it("saved state is reloaded on next configure", function()
			local state_file = vim.fn.tempname() .. "_coach_persist.json"

			package.loaded["coach.exercises"] = nil
			package.loaded["coach.sets"] = nil
			package.loaded["coach.sources"] = nil
			package.loaded["coach.builtin"] = nil
			package.loaded["coach.exercises_data"] = nil
			local sets1 = require("coach.sets")
			sets1._set_state_file(state_file)
			sets1.configure({})
			sets1.switch("neovim-manual", "03-making-changes")

			package.loaded["coach.exercises"] = nil
			package.loaded["coach.sets"] = nil
			package.loaded["coach.sources"] = nil
			package.loaded["coach.builtin"] = nil
			package.loaded["coach.exercises_data"] = nil
			local sets2 = require("coach.sets")
			sets2._set_state_file(state_file)
			sets2.configure({})
			eq("03-making-changes", sets2.get_active().volume)
		end)
	end)
end)

h.summary()
