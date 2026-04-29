local h = require("harness")
local describe, it, eq, is_true, is_false = h.describe, h.it, h.eq, h.is_true, h.is_false

-- Use a temp file for each test run
local tmp_file = vim.fn.tempname() .. "_coach_test.json"

--- Force a fresh progress module by clearing the require cache
local function fresh_progress()
	package.loaded["coach.progress"] = nil
	package.loaded["coach.exercises"] = nil
	package.loaded["coach.sets"] = nil
	package.loaded["coach.sources"] = nil
	package.loaded["coach.builtin"] = nil

	local sets = require("coach.sets")
	sets._set_state_file(vim.fn.tempname() .. "_coach_state.json")
	sets.configure({ active = "neovim-manual/01-first-steps" })

	local progress = require("coach.progress")
	progress.configure({ progress_file = tmp_file, required_reps = 3 })
	progress.load()
	return progress
end

--- Clean up temp file
local function cleanup()
	os.remove(tmp_file)
end

describe("progress", function()
	describe("initial state", function()
		it("starts at exercise 1", function()
			cleanup()
			local p = fresh_progress()
			eq(1, p.get_exercise_index())
		end)

		it("starts with empty counts", function()
			cleanup()
			local p = fresh_progress()
			local counts = p.get_counts()
			eq(0, vim.tbl_count(counts))
		end)

		it("no actions are complete", function()
			cleanup()
			local p = fresh_progress()
			is_false(p.is_action_complete("i"))
			is_false(p.is_exercise_complete())
		end)
	end)

	describe("increment", function()
		it("increments action count", function()
			cleanup()
			local p = fresh_progress()
			eq(1, p.increment("i"))
			eq(2, p.increment("i"))
			eq(3, p.increment("i"))
		end)

		it("does not exceed required_reps", function()
			cleanup()
			local p = fresh_progress()
			for _ = 1, 5 do
				p.increment("i")
			end
			eq(3, p.get_count("i"))
		end)

		it("tracks different actions independently", function()
			cleanup()
			local p = fresh_progress()
			-- exercise 1 is 02.2 which only has "i", advance to 02.3 which has hjkl
			p.increment("i")
			p.increment("i")
			p.increment("i")
			p.advance()
			p.increment("h")
			p.increment("j")
			eq(1, p.get_count("h"))
			eq(1, p.get_count("j"))
			eq(0, p.get_count("k"))
		end)
	end)

	describe("decrement", function()
		it("decrements an action count", function()
			cleanup()
			local p = fresh_progress()
			p.increment("i")
			p.increment("i")
			eq(2, p.get_count("i"))
			eq(1, p.decrement("i"))
			eq(1, p.get_count("i"))
		end)

		it("floors at zero", function()
			cleanup()
			local p = fresh_progress()
			eq(0, p.decrement("i"))
			eq(0, p.get_count("i"))
		end)

		it("does not go negative even when called repeatedly", function()
			cleanup()
			local p = fresh_progress()
			p.increment("i")
			p.decrement("i")
			p.decrement("i")
			p.decrement("i")
			eq(0, p.get_count("i"))
		end)

		it("affects only the named action", function()
			cleanup()
			local p = fresh_progress()
			-- advance to 02.3 (h, j, k, l)
			for _ = 1, 3 do
				p.increment("i")
			end
			p.advance()
			p.increment("h")
			p.increment("j")
			p.decrement("h")
			eq(0, p.get_count("h"))
			eq(1, p.get_count("j"))
		end)
	end)

	describe("is_action_complete", function()
		it("returns false when under required_reps", function()
			cleanup()
			local p = fresh_progress()
			p.increment("i")
			is_false(p.is_action_complete("i"))
		end)

		it("returns true when at required_reps", function()
			cleanup()
			local p = fresh_progress()
			for _ = 1, 3 do
				p.increment("i")
			end
			is_true(p.is_action_complete("i"))
		end)
	end)

	describe("is_exercise_complete", function()
		it("returns false when not all actions done", function()
			cleanup()
			local p = fresh_progress()
			-- advance to exercise 2 (02.3: h,j,k,l)
			for _ = 1, 3 do
				p.increment("i")
			end
			p.advance()
			for _ = 1, 3 do
				p.increment("h")
			end
			for _ = 1, 3 do
				p.increment("j")
			end
			is_false(p.is_exercise_complete())
		end)

		it("returns true when all actions done", function()
			cleanup()
			local p = fresh_progress()
			-- exercise 1 (02.2) has only "i"
			for _ = 1, 3 do
				p.increment("i")
			end
			is_true(p.is_exercise_complete())
		end)
	end)

	describe("advance", function()
		it("moves to next exercise", function()
			cleanup()
			local p = fresh_progress()
			eq(1, p.get_exercise_index())
			is_true(p.advance())
			eq(2, p.get_exercise_index())
		end)

		it("returns false at last exercise", function()
			cleanup()
			local p = fresh_progress()
			local exercises = require("coach.exercises")
			-- advance to last
			for _ = 1, exercises.count() - 1 do
				p.advance()
			end
			eq(exercises.count(), p.get_exercise_index())
			is_false(p.advance())
			eq(exercises.count(), p.get_exercise_index())
		end)
	end)

	describe("go_back", function()
		it("moves to previous exercise", function()
			cleanup()
			local p = fresh_progress()
			p.advance()
			p.advance()
			eq(3, p.get_exercise_index())
			is_true(p.go_back())
			eq(2, p.get_exercise_index())
		end)

		it("returns false at first exercise", function()
			cleanup()
			local p = fresh_progress()
			eq(1, p.get_exercise_index())
			is_false(p.go_back())
			eq(1, p.get_exercise_index())
		end)
	end)

	describe("reset_current", function()
		it("clears counts for current exercise", function()
			cleanup()
			local p = fresh_progress()
			p.increment("i")
			p.increment("i")
			eq(2, p.get_count("i"))
			p.reset_current()
			eq(0, p.get_count("i"))
		end)

		it("does not change exercise index", function()
			cleanup()
			local p = fresh_progress()
			p.advance()
			eq(2, p.get_exercise_index())
			p.reset_current()
			eq(2, p.get_exercise_index())
		end)
	end)

	describe("reset_all", function()
		it("resets to exercise 1 with empty counts", function()
			cleanup()
			local p = fresh_progress()
			p.increment("i")
			p.advance()
			p.increment("h")
			eq(2, p.get_exercise_index())
			p.reset_all()
			eq(1, p.get_exercise_index())
			eq(0, p.get_count("i"))
		end)
	end)

	describe("save and load", function()
		it("persists exercise index", function()
			cleanup()
			local p = fresh_progress()
			p.advance()
			p.advance()
			p.save()

			local p2 = fresh_progress() -- calls load() internally
			eq(3, p2.get_exercise_index())
		end)

		it("persists action counts", function()
			cleanup()
			local p = fresh_progress()
			p.increment("i")
			p.increment("i")
			p.save()

			local p2 = fresh_progress()
			eq(2, p2.get_count("i"))
		end)

		it("handles missing file gracefully", function()
			cleanup()
			local p = fresh_progress()
			eq(1, p.get_exercise_index())
			eq(0, vim.tbl_count(p.get_counts()))
		end)

		it("handles corrupt file gracefully", function()
			cleanup()
			local f = assert(io.open(tmp_file, "w"))
			f:write("not json{{{")
			f:close()
			local p = fresh_progress()
			eq(1, p.get_exercise_index())
		end)
	end)

	describe("get_required_reps", function()
		it("returns configured value", function()
			cleanup()
			local p = fresh_progress()
			eq(3, p.get_required_reps())
		end)
	end)

	describe("is_welcome_pending", function()
		it("returns true on fresh start (no file)", function()
			cleanup()
			local p = fresh_progress()
			is_true(p.is_welcome_pending())
		end)
		it("returns false after mark_welcome_shown", function()
			cleanup()
			local p = fresh_progress()
			p.mark_welcome_shown()
			is_false(p.is_welcome_pending())
		end)
		it("persists across save/load", function()
			cleanup()
			local p = fresh_progress()
			p.mark_welcome_shown()
			p.save()
			local p2 = fresh_progress()
			is_false(p2.is_welcome_pending())
		end)
		it("remains pending when saved without marking", function()
			cleanup()
			local p = fresh_progress()
			p.save()
			local p2 = fresh_progress()
			is_true(p2.is_welcome_pending())
		end)
	end)

	describe("go_to", function()
		it("jumps to the specified exercise index", function()
			cleanup()
			local p = fresh_progress()
			p.go_to(3)
			eq(3, p.get_exercise_index())
		end)
		it("clamps to 1 at lower bound", function()
			cleanup()
			local p = fresh_progress()
			p.go_to(0)
			eq(1, p.get_exercise_index())
		end)
		it("clamps to last exercise at upper bound", function()
			cleanup()
			local p = fresh_progress()
			local exercises = require("coach.exercises")
			p.go_to(999)
			eq(exercises.count(), p.get_exercise_index())
		end)
		it("persists after save/load", function()
			cleanup()
			local p = fresh_progress()
			p.go_to(5)
			p.save()
			local p2 = fresh_progress()
			eq(5, p2.get_exercise_index())
		end)
	end)

	describe("get_all_exercise_counts", function()
		it("returns empty table on fresh start", function()
			cleanup()
			local p = fresh_progress()
			local all = p.get_all_exercise_counts()
			eq(0, vim.tbl_count(all))
		end)
		it("includes counts from completed exercises", function()
			cleanup()
			local p = fresh_progress()
			for _ = 1, 3 do
				p.increment("i")
			end
			p.advance()
			for _ = 1, 2 do
				p.increment("h")
			end
			local all = p.get_all_exercise_counts()
			eq(3, all["02.2"] and all["02.2"]["i"] or 0)
			eq(2, all["02.3"] and all["02.3"]["h"] or 0)
		end)
	end)

	describe("is_exercise_complete with shadowed", function()
		it("shadowed action does not block completion", function()
			cleanup()
			local p = fresh_progress()
			-- exercise 1 (02.2) has only "i" — mark it shadowed
			is_true(p.is_exercise_complete({ ["i"] = true }))
		end)

		it("non-shadowed incomplete action still blocks", function()
			cleanup()
			local p = fresh_progress()
			-- advance to exercise 2 (02.3: h, j, k, l)
			for _ = 1, 3 do
				p.increment("i")
			end
			p.advance()
			-- complete h and j but not k and l; shadow k
			for _ = 1, 3 do
				p.increment("h")
			end
			for _ = 1, 3 do
				p.increment("j")
			end
			is_false(p.is_exercise_complete({ ["k"] = true }))
		end)

		it("all non-shadowed done means exercise complete", function()
			cleanup()
			local p = fresh_progress()
			-- advance to exercise 2
			for _ = 1, 3 do
				p.increment("i")
			end
			p.advance()
			-- complete h and j; shadow k and l
			for _ = 1, 3 do
				p.increment("h")
			end
			for _ = 1, 3 do
				p.increment("j")
			end
			is_true(p.is_exercise_complete({ ["k"] = true, ["l"] = true }))
		end)

		it("nil shadowed behaves like no shadowed", function()
			cleanup()
			local p = fresh_progress()
			is_false(p.is_exercise_complete(nil))
			for _ = 1, 3 do
				p.increment("i")
			end
			is_true(p.is_exercise_complete(nil))
		end)
	end)

	describe("coaching_active", function()
		it("defaults to false on fresh start", function()
			cleanup()
			local p = fresh_progress()
			is_false(p.is_coaching_active())
		end)
		it("can be set to true", function()
			cleanup()
			local p = fresh_progress()
			p.set_coaching_active(true)
			is_true(p.is_coaching_active())
		end)
		it("persists across save/load", function()
			cleanup()
			local p = fresh_progress()
			p.set_coaching_active(true)
			p.save()
			local p2 = fresh_progress()
			is_true(p2.is_coaching_active())
		end)
		it("persists false across save/load", function()
			cleanup()
			local p = fresh_progress()
			p.set_coaching_active(false)
			p.save()
			local p2 = fresh_progress()
			is_false(p2.is_coaching_active())
		end)
	end)

	describe("window_visible", function()
		it("defaults to true on fresh start", function()
			cleanup()
			local p = fresh_progress()
			is_true(p.is_window_visible())
		end)
		it("can be set to false", function()
			cleanup()
			local p = fresh_progress()
			p.set_window_visible(false)
			is_false(p.is_window_visible())
		end)
		it("persists across save/load", function()
			cleanup()
			local p = fresh_progress()
			p.set_window_visible(false)
			p.save()
			local p2 = fresh_progress()
			is_false(p2.is_window_visible())
		end)
		it("persists true across save/load", function()
			cleanup()
			local p = fresh_progress()
			p.set_window_visible(true)
			p.save()
			local p2 = fresh_progress()
			is_true(p2.is_window_visible())
		end)
	end)

	describe("per-exercise required_reps", function()
		it("exercise required_reps overrides global for increment cap", function()
			cleanup()
			local p = fresh_progress() -- global required_reps = 3
			local exercises = require("coach.exercises")
			exercises.list[1].required_reps = 2

			p.increment("i")
			p.increment("i")
			p.increment("i")
			eq(2, p.get_count("i"))
		end)

		it("exercise required_reps overrides global for is_action_complete", function()
			cleanup()
			local p = fresh_progress()
			local exercises = require("coach.exercises")
			exercises.list[1].required_reps = 1

			p.increment("i")
			is_true(p.is_action_complete("i"))
		end)

		it("exercise required_reps overrides global for is_exercise_complete", function()
			cleanup()
			local p = fresh_progress()
			local exercises = require("coach.exercises")
			exercises.list[1].required_reps = 1

			p.increment("i")
			is_true(p.is_exercise_complete())
		end)

		it("falls back to global required_reps when not set on exercise", function()
			cleanup()
			local p = fresh_progress() -- global required_reps = 3
			local exercises = require("coach.exercises")
			exercises.list[1].required_reps = nil

			p.increment("i")
			p.increment("i")
			is_false(p.is_action_complete("i"))
			p.increment("i")
			is_true(p.is_action_complete("i"))
		end)
	end)
end)

cleanup()
h.summary()
