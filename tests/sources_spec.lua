local h = require("harness")
local describe, it, eq, is_true, is_false = h.describe, h.it, h.eq, h.is_true, h.is_false

local sources = require("coach.sources")

describe("sources.kind", function()
	it("treats nil as builtin", function()
		eq("builtin", sources.kind(nil))
	end)
	it("treats 'builtin' as builtin", function()
		eq("builtin", sources.kind("builtin"))
	end)
	it("treats github: prefix as github", function()
		eq("github", sources.kind("github:owner/repo"))
	end)
	it("everything else is a dir", function()
		eq("dir", sources.kind("~/some/path"))
		eq("dir", sources.kind("/abs/path"))
	end)
end)

describe("sources.parse_github", function()
	it("parses owner/repo", function()
		local repo, ref = sources.parse_github("github:tpope/vim-surround")
		eq("tpope/vim-surround", repo)
		h.is_nil(ref)
	end)
	it("parses owner/repo@ref", function()
		local repo, ref = sources.parse_github("github:tpope/vim-surround@v1.0")
		eq("tpope/vim-surround", repo)
		eq("v1.0", ref)
	end)
end)

describe("sources.valid_set", function()
	it("accepts a well-formed set", function()
		is_true(sources.valid_set({
			id = "x.1",
			title = "T",
			exercises = { { exercise = "w", display = "w", desc = "word" } },
		}))
	end)
	it("rejects missing id", function()
		is_false(sources.valid_set({ title = "t", exercises = { { exercise = "w", display = "w", desc = "d" } } }))
	end)
	it("rejects empty exercises", function()
		is_false(sources.valid_set({ id = "x", title = "t", exercises = {} }))
	end)
	it("rejects malformed exercise entries", function()
		is_false(sources.valid_set({ id = "x", title = "t", exercises = { { exercise = "w" } } }))
	end)
	-- The second return value is what the warning says. A boolean alone produced
	-- "skipped invalid set: win.1" nine times over on startup, naming neither what
	-- was wrong nor what to do -- and the answer was that the whole program used the
	-- older `actions`/`action` spelling.
	describe("says why it rejected the set", function()
		---@param set any
		---@return string
		local function why(set)
			local _, reason = sources.valid_set(set)
			return reason or ""
		end

		it("gives no reason for a valid set", function()
			local ok, reason = sources.valid_set({
				id = "x",
				title = "t",
				exercises = { { exercise = "w", display = "w", desc = "d" } },
			})
			is_true(ok)
			eq(nil, reason)
		end)

		it("names a missing id", function()
			local reason = why({ title = "t", exercises = { { exercise = "w", display = "w", desc = "d" } } })
			is_true(reason:find("id") ~= nil, reason)
		end)

		it("names a missing title", function()
			local reason = why({ id = "x", exercises = { { exercise = "w", display = "w", desc = "d" } } })
			is_true(reason:find("title") ~= nil, reason)
		end)

		it("names a missing exercises list", function()
			local reason = why({ id = "x", title = "t" })
			is_true(reason:find("exercises") ~= nil, reason)
		end)

		it("points at the older actions spelling when that is what it finds", function()
			-- The one third-party program in play used it, and the fix is a rename,
			-- not a debugging session.
			local reason = why({
				id = "win.1",
				title = "Opening Splits",
				actions = { { action = "<C-w>s", display = "Ctrl-W s", desc = "Split" } },
			})
			is_true(reason:find("actions") ~= nil, reason)
			is_true(reason:find("exercises") ~= nil, reason)
		end)

		it("names which exercise of the list is at fault, and what it lacks", function()
			local reason = why({
				id = "x",
				title = "t",
				exercises = {
					{ exercise = "w", display = "w", desc = "d" },
					{ exercise = "e", display = "e" },
				},
			})
			is_true(reason:find("2") ~= nil, reason)
			is_true(reason:find("desc") ~= nil, reason)
		end)

		it("names a missing exercise string", function()
			local reason = why({ id = "x", title = "t", exercises = { { display = "w", desc = "d" } } })
			is_true(reason:find("exercise") ~= nil, reason)
		end)

		it("says a set is not a table at all", function()
			is_true(#why("nope") > 0)
		end)
	end)
end)

describe("sources.load warnings", function()
	local dir = vim.fn.tempname() .. "_coach_warn_dir"
	vim.fn.mkdir(dir .. "/nested", "p")

	local function write(path, contents)
		local f = assert(io.open(path, "w"))
		f:write(contents)
		f:close()
	end

	-- Three sets in the old spelling, one good: the shape of the real case.
	write(
		dir .. "/01-stale.lua",
		[[return {
			{ id = 'win.1', title = 'A', actions = { { action = '<C-w>s', display = 's', desc = 'd' } } },
			{ id = 'win.2', title = 'B', actions = { { action = '<C-w>v', display = 'v', desc = 'd' } } },
			{ id = 'win.3', title = 'C', actions = { { action = '<C-w>n', display = 'n', desc = 'd' } } },
			{ id = 'win.4', title = 'D', exercises = { { exercise = 'w', display = 'w', desc = 'd' } } },
		}]]
	)
	write(
		dir .. "/nested/02-deep.lua",
		"return { { id = 'n.1', title = 'N', exercises = { { exercise = 'b', display = 'b', desc = 'd' } } } }"
	)

	--- Capture what `load` notifies.
	---@return string[]
	local function warnings_from_load()
		local captured = {}
		local original = vim.notify
		---@diagnostic disable-next-line: duplicate-set-field
		vim.notify = function(msg)
			captured[#captured + 1] = msg
		end
		local ok, err = pcall(sources.load, { name = "warn", source = dir })
		vim.notify = original
		is_true(ok, tostring(err))
		return captured
	end

	it("warns once per file, not once per set", function()
		-- Nine notifications at startup is what made this worth changing.
		eq(1, #warnings_from_load())
	end)

	it("says how many sets it skipped", function()
		local msg = warnings_from_load()[1]
		is_true(msg:find("3") ~= nil, msg)
	end)

	it("names the file and the offending sets, with reasons", function()
		local msg = warnings_from_load()[1]
		is_true(msg:find("01-stale", 1, true) ~= nil, msg)
		is_true(msg:find("win.1", 1, true) ~= nil, msg)
		is_true(msg:find("actions", 1, true) ~= nil, msg)
	end)

	it("keeps the valid sets of a file that also had invalid ones", function()
		local sessions = sources.load({ name = "warn", source = dir })
		for _, s in ipairs(sessions) do
			if s.name == "01-stale" then
				eq(1, #s.sets)
				eq("win.4", s.sets[1].id)
				return
			end
		end
		error("01-stale should still have loaded")
	end)

	-- A github program scans root plus immediate subdirectories "so any repo layout
	-- works"; a local directory read only its root, so the same repo checked out
	-- locally lost every session in a subdirectory. One rule for both.
	it("scans immediate subdirectories of a local dir too", function()
		local sessions = sources.load({ name = "warn", source = dir })
		local names = {}
		for _, s in ipairs(sessions) do
			names[s.name] = true
		end
		is_true(names["02-deep"] == true, "02-deep not loaded from a subdirectory")
	end)
end)

describe("sources.load (builtin)", function()
	it("returns multiple sessions", function()
		local sessions = sources.load({ name = "user-manual" })
		is_true(#sessions > 1)
	end)
	it("first builtin session is 01-first-steps", function()
		local sessions = sources.load({ name = "user-manual" })
		eq("01-first-steps", sessions[1].name)
	end)
end)

describe("sources.load (local dir)", function()
	-- Build a temp dir with two session files + one invalid file.
	local dir = vim.fn.tempname() .. "_coach_src_dir"
	vim.fn.mkdir(dir, "p")

	local function write(path, contents)
		local f = assert(io.open(path, "w"))
		f:write(contents)
		f:close()
	end

	write(
		dir .. "/01-alpha.lua",
		"return { { id = 'a.1', title = 'A', exercises = { { exercise = 'w', display = 'w', desc = 'd' } } } }"
	)
	write(
		dir .. "/02-beta.lua",
		"return { { id = 'b.1', title = 'B', exercises = { { exercise = 'e', display = 'e', desc = 'd' } } } }"
	)
	write(dir .. "/99-bad.lua", "return 'not a table'")

	it("loads *.lua files as sessions in sorted order", function()
		local sessions = sources.load({ name = "custom", source = dir })
		eq(2, #sessions)
		eq("01-alpha", sessions[1].name)
		eq("02-beta", sessions[2].name)
	end)

	it("skips files that do not return a table", function()
		local sessions = sources.load({ name = "custom", source = dir })
		for _, s in ipairs(sessions) do
			if s.name == "99-bad" then
				error("bad session should have been skipped")
			end
		end
	end)

	it("each session has its sets", function()
		local sessions = sources.load({ name = "custom", source = dir })
		eq(1, #sessions[1].sets)
		eq("a.1", sessions[1].sets[1].id)
	end)

	it("handles non-existent directory", function()
		local sessions = sources.load({ name = "nope", source = "/does/not/exist" })
		eq(0, #sessions)
	end)

	-- A session may name itself, for the sidebar and the picker to show instead of
	-- the file stem. The type said so all along; nothing read it.
	describe("session title", function()
		local titled = vim.fn.tempname() .. "_coach_titled"
		vim.fn.mkdir(titled, "p")
		write(
			titled .. "/03-gamma.lua",
			"return { title = 'Third Chapter', { id = 'c.1', title = 'C', exercises = { { exercise = 'b', display = 'b', desc = 'd' } } } }"
		)
		write(
			titled .. "/04-delta.lua",
			"return { { id = 'd.1', title = 'D', exercises = { { exercise = 'B', display = 'B', desc = 'd' } } } }"
		)
		write(
			titled .. "/05-epsilon.lua",
			"return { title = 42, { id = 'e.1', title = 'E', exercises = { { exercise = '0', display = '0', desc = 'd' } } } }"
		)

		local function session(name)
			for _, s in ipairs(sources.load({ name = "titled", source = titled })) do
				if s.name == name then
					return s
				end
			end
			return nil
		end

		it("is read from the session file", function()
			eq("Third Chapter", assert(session("03-gamma")).title)
		end)

		it("is nil when the file does not declare one", function()
			eq(nil, assert(session("04-delta")).title)
		end)

		it("is ignored when it is not a string", function()
			eq(nil, assert(session("05-epsilon")).title)
		end)

		it("does not become a set", function()
			eq(1, #assert(session("03-gamma")).sets)
		end)
	end)
end)

describe("sources github deep scan", function()
	local repo_dir = vim.fn.tempname() .. "_coach_deep_repo"
	vim.fn.mkdir(repo_dir .. "/basics", "p")

	local function write(path, contents)
		local f = assert(io.open(path, "w"))
		f:write(contents)
		f:close()
	end
	write(
		repo_dir .. "/basics/01-windows.lua",
		"return { { id = 'win.1', title = 'W', exercises = { { exercise = '<C-w>s', display = 'Ctrl-W s', desc = 'split' } } } }"
	)
	write(
		repo_dir .. "/basics/02-marks.lua",
		"return { { id = 'mark.1', title = 'M', exercises = { { exercise = 'ma', display = 'ma', desc = 'set mark' } } } }"
	)

	it("finds sessions in a subdir of the repo root", function()
		-- Simulate a github program by overriding cache_dir to point at our fake repo.
		local orig_cache = sources.cache_dir
		---@diagnostic disable-next-line: duplicate-set-field
		sources.cache_dir = function(_) return repo_dir end
		local sessions = sources.load({ name = "extras", source = "github:test/repo" })
		---@diagnostic disable-next-line: duplicate-set-field
		sources.cache_dir = orig_cache
		eq(2, #sessions)
		eq("01-windows", sessions[1].name)
		eq("02-marks", sessions[2].name)
	end)
end)

describe("sources.is_ready", function()
	it("is always true for builtin", function()
		is_true(sources.is_ready({ name = "user-manual" }))
	end)
	it("is true for an existing dir", function()
		local dir = vim.fn.tempname() .. "_coach_ready"
		vim.fn.mkdir(dir, "p")
		is_true(sources.is_ready({ name = "x", source = dir }))
	end)
	it("is false for a missing dir", function()
		is_false(sources.is_ready({ name = "x", source = "/definitely/not/here" }))
	end)
end)

h.summary()
