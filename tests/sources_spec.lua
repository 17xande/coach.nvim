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
