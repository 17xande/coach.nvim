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

describe("sources.valid_chapter", function()
	it("accepts a well-formed chapter", function()
		is_true(sources.valid_chapter({
			id = "x.1",
			title = "T",
			actions = { { action = "w", display = "w", desc = "word" } },
		}))
	end)
	it("rejects missing id", function()
		is_false(sources.valid_chapter({ title = "t", actions = { { action = "w", display = "w", desc = "d" } } }))
	end)
	it("rejects empty actions", function()
		is_false(sources.valid_chapter({ id = "x", title = "t", actions = {} }))
	end)
	it("rejects malformed action entries", function()
		is_false(sources.valid_chapter({ id = "x", title = "t", actions = { { action = "w" } } }))
	end)
end)

describe("sources.load (builtin)", function()
	it("returns multiple volumes", function()
		local vols = sources.load({ name = "neovim-manual" })
		is_true(#vols > 1)
	end)
	it("first builtin volume is 01-first-steps", function()
		local vols = sources.load({ name = "neovim-manual" })
		eq("01-first-steps", vols[1].name)
	end)
end)

describe("sources.load (local dir)", function()
	-- Build a temp dir with two volume files + one invalid file.
	local dir = vim.fn.tempname() .. "_coach_src_dir"
	vim.fn.mkdir(dir, "p")

	local function write(path, contents)
		local f = assert(io.open(path, "w"))
		f:write(contents)
		f:close()
	end

	write(
		dir .. "/01-alpha.lua",
		"return { { id = 'a.1', title = 'A', actions = { { action = 'w', display = 'w', desc = 'd' } } } }"
	)
	write(
		dir .. "/02-beta.lua",
		"return { { id = 'b.1', title = 'B', actions = { { action = 'e', display = 'e', desc = 'd' } } } }"
	)
	write(dir .. "/99-bad.lua", "return 'not a table'")

	-- Simulate a github repo where volumes are inside a subdir.
	local repo_dir = vim.fn.tempname() .. "_coach_repo"
	vim.fn.mkdir(repo_dir .. "/basics", "p")
	write(
		repo_dir .. "/basics/01-windows.lua",
		"return { { id = 'win.1', title = 'Windows', actions = { { action = '<C-w>s', display = 'Ctrl-W s', desc = 'split' } } } }"
	)
	write(
		repo_dir .. "/basics/02-marks.lua",
		"return { { id = 'mark.1', title = 'Marks', actions = { { action = 'ma', display = 'ma', desc = 'set mark' } } } }"
	)

	it("loads *.lua files as volumes in sorted order", function()
		local vols = sources.load({ name = "custom", source = dir })
		eq(2, #vols)
		eq("01-alpha", vols[1].name)
		eq("02-beta", vols[2].name)
	end)

	it("skips files that do not return a table", function()
		local vols = sources.load({ name = "custom", source = dir })
		for _, v in ipairs(vols) do
			if v.name == "99-bad" then
				error("bad volume should have been skipped")
			end
		end
	end)

	it("each volume has its chapters", function()
		local vols = sources.load({ name = "custom", source = dir })
		eq(1, #vols[1].chapters)
		eq("a.1", vols[1].chapters[1].id)
	end)

	it("handles non-existent directory", function()
		local vols = sources.load({ name = "nope", source = "/does/not/exist" })
		eq(0, #vols)
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
		"return { { id = 'win.1', title = 'W', actions = { { action = '<C-w>s', display = 'Ctrl-W s', desc = 'split' } } } }"
	)
	write(
		repo_dir .. "/basics/02-marks.lua",
		"return { { id = 'mark.1', title = 'M', actions = { { action = 'ma', display = 'ma', desc = 'set mark' } } } }"
	)

	it("finds volumes in a subdir of the repo root", function()
		-- Simulate a github set by overriding cache_dir to point at our fake repo.
		local orig_cache = sources.cache_dir
		---@diagnostic disable-next-line: duplicate-set-field
		sources.cache_dir = function(_) return repo_dir end
		local vols = sources.load({ name = "extras", source = "github:test/repo" })
		---@diagnostic disable-next-line: duplicate-set-field
		sources.cache_dir = orig_cache
		eq(2, #vols)
		eq("01-windows", vols[1].name)
		eq("02-marks", vols[2].name)
	end)
end)

describe("sources.is_ready", function()
	it("is always true for builtin", function()
		is_true(sources.is_ready({ name = "neovim-manual" }))
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
