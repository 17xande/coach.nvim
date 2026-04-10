NVIM := nvim --headless -u tests/minimal_init.lua

.PHONY: test test-exercises test-progress test-window test-tracker test-keybinds test-index

test: test-exercises test-progress test-window test-tracker test-keybinds test-index

test-exercises:
	$(NVIM) -c "luafile tests/exercises_spec.lua" -c "qa"

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
