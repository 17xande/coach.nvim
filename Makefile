NVIM := nvim --headless -u tests/minimal_init.lua

.PHONY: test test-exercises test-progress test-window test-tracker

test: test-exercises test-progress test-window test-tracker

test-exercises:
	$(NVIM) -c "luafile tests/exercises_spec.lua" -c "qa"

test-progress:
	$(NVIM) -c "luafile tests/progress_spec.lua" -c "qa"

test-window:
	$(NVIM) -c "luafile tests/window_spec.lua" -c "qa"

test-tracker:
	$(NVIM) -c "luafile tests/tracker_spec.lua" -c "qa"
