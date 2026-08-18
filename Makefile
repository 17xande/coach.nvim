NVIM := nvim --headless -u tests/minimal_init.lua

# Every spec, discovered rather than listed, so adding one cannot leave it
# unrun. `make test-emit` still works: see the pattern rule below.
SPECS := $(sort $(wildcard tests/*_spec.lua))

# A spec that drives keys can hang inside nvim_feedkeys, which is synchronous C
# that no Lua watchdog can interrupt, so the wall clock is the only backstop.
# And `qa!`, never `qa`: a spec that leaves a modified buffer turns a plain :qa
# into a "No write since last change" prompt, and headless then waits forever.
TIMEOUT := timeout 120

.PHONY: test check preflight

# The precondition for everything else: coach tracks nothing without
# track-action, and track-action reports nothing without CmdAtom (Neovim 0.13).
# A missing event has to fail loudly here rather than produce a green suite that
# asserted nothing -- every emit check would simply see no actions.
preflight:
	@nvim --headless --clean -c 'luafile tests/preflight.lua' -c 'qa!'
	@echo "preflight ok: $$(nvim --version | head -1)"

test: preflight
	@for spec in $(SPECS); do \
		echo "=== $$spec"; \
		$(TIMEOUT) $(NVIM) -c "luafile $$spec" -c "qa!" || exit 1; \
	done

# One spec by name: `make test-tracker` runs tests/tracker_spec.lua.
test-%:
	$(TIMEOUT) $(NVIM) -c "luafile tests/$*_spec.lua" -c "qa!"

# Static analysis. lua-language-server comes from PATH (mise), not from Mason:
# the Mason path is an artifact of one machine's Neovim install.
check:
	lua-language-server --check lua/ --checklevel=Warning \
		--configpath=$(CURDIR)/.luarc.json --logpath=/tmp/lua-ls-check-coach
