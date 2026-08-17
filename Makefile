NVIM := nvim --headless -u tests/minimal_init.lua

.PHONY: test test-sets test-progress test-window test-tracker test-keybinds test-index test-sources test-programs test-reset test-emit

test: test-sets test-progress test-window test-tracker test-keybinds test-index test-sources test-programs test-reset test-emit

# Checks every builtin exercise against track-action's real parser. Skips itself if
# track-action.nvim is neither on the runtimepath nor a sibling checkout.
test-emit:
	$(NVIM) -c "luafile tests/emit_spec.lua" -c "qa"

test-reset:
	$(NVIM) -c "luafile tests/reset_spec.lua" -c "qa"

test-sources:
	$(NVIM) -c "luafile tests/sources_spec.lua" -c "qa"

test-programs:
	$(NVIM) -c "luafile tests/programs_spec.lua" -c "qa"

test-sets:
	$(NVIM) -c "luafile tests/sets_spec.lua" -c "qa"

test-progress:
	$(NVIM) -c "luafile tests/progress_spec.lua" -c "qa"

test-window:
	$(NVIM) -c "luafile tests/window_spec.lua" -c "qa"

test-tracker:
	$(NVIM) -c "luafile tests/tracker_spec.lua" -c "qa"

test-keybinds:
	$(NVIM) -c "luafile tests/keybinds_spec.lua" -c "qa"

test-index:
	$(NVIM) -c "luafile tests/index_spec.lua" -c "qa"
