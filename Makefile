evdev-dump-events uinput-pointer:
	hare build -levdev -o $@ tools/$@/
.PHONY: evdev-dump-events uinput-pointer
