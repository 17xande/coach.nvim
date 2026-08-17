-- Doc spec: the help file has to keep up with the code
--
-- Documentation drifts silently -- a command gets added, the help file does not
-- mention it, and nobody notices because nothing fails. This spec reads the command
-- and option names out of the source and requires a help tag for each, so adding
-- one without documenting it fails the suite.

local h = require("harness")
local describe, it, is_true, eq = h.describe, h.it, h.is_true, h.eq

local DOC = "doc/coach.txt"

--- Whole file as one string.
---@param path string
---@return string
local function read(path)
	local f = assert(io.open(path, "r"), path .. " is missing")
	local content = f:read("*a")
	f:close()
	return content
end

local doc = read(DOC)
local init_src = read("lua/coach/init.lua")

--- Every `*tag*` in the help file.
---@return table<string, boolean>
local function doc_tags()
	local tags = {}
	for tag in doc:gmatch("%*([^%s*|]+)%*") do
		tags[tag] = true
	end
	return tags
end

local TAGS = doc_tags()

--- Every `:Coach…` command the plugin creates.
---@return string[]
local function commands()
	local out = {}
	for name in init_src:gmatch('nvim_create_user_command%("(Coach%w+)"') do
		out[#out + 1] = name
	end
	table.sort(out)
	return out
end

--- Every key of the `keybinds` table in setup().
---@return string[]
local function keybind_names()
	local block = init_src:match("local keys = vim%.tbl_extend%(\"force\", {(.-)}") or ""
	local out = {}
	for name in block:gmatch("(%w+)%s*=") do
		out[#out + 1] = name
	end
	table.sort(out)
	return out
end

describe("doc/coach.txt", function()
	it("exists and is not a stub", function()
		is_true(#doc > 2000, "help file length: " .. #doc)
	end)

	it("declares its own help tag", function()
		is_true(TAGS["coach.nvim"] ~= nil or TAGS["coach"] ~= nil, "no coach tag")
	end)

	it("ends every line within vimdoc's 78 columns", function()
		local long = {}
		for i, line in ipairs(vim.split(doc, "\n")) do
			if vim.fn.strdisplaywidth(line) > 78 then
				long[#long + 1] = ("line %d (%d cols)"):format(i, vim.fn.strdisplaywidth(line))
			end
		end
		eq(0, #long, "over-long lines: " .. table.concat(long, ", "))
	end)

	it("has a modeline so :help renders it", function()
		is_true(doc:find("vim:tw=78:ts=8:noet:ft=help:norl:", 1, true) ~= nil)
	end)

	describe("commands", function()
		local cmds = commands()

		it("found the commands in the source at all", function()
			is_true(#cmds >= 15, "found " .. #cmds)
		end)

		for _, name in ipairs(cmds) do
			it(":" .. name .. " has a help tag", function()
				is_true(TAGS[":" .. name] ~= nil, "no *:" .. name .. "* tag in " .. DOC)
			end)
		end
	end)

	describe("setup options", function()
		-- Read from the type annotation on setup(), which is the closest thing to a
		-- declared list of options.
		local block = init_src:match("%-%-%-@param opts%? {(.-)\n%-%-%- }")
		local options = {}
		-- Three spaces of indentation is a top-level option; nested tables are
		-- indented further and documented under their parent's tag.
		for name in (block or ""):gmatch("\n%-%-%-   ([%w_]+)%??:") do
			options[#options + 1] = name
		end
		table.sort(options)

		it("found the options in the source at all", function()
			is_true(#options >= 6, "found " .. #options .. ": " .. table.concat(options, ", "))
		end)

		for _, name in ipairs(options) do
			it(name .. " has a help tag", function()
				is_true(TAGS["coach-opt-" .. name] ~= nil, "no *coach-opt-" .. name .. "* tag in " .. DOC)
			end)
		end
	end)

	describe("default keybinds", function()
		local names = keybind_names()

		it("found the keybind names in the source at all", function()
			is_true(#names >= 8, "found " .. #names .. ": " .. table.concat(names, ", "))
		end)

		for _, name in ipairs(names) do
			it(name .. " is mentioned", function()
				is_true(doc:find("keybinds." .. name, 1, true) ~= nil, "keybinds." .. name .. " not in " .. DOC)
			end)
		end
	end)
end)

h.summary()
