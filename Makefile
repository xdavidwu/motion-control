evdev-dump-events uinput-pointer:
	hare build -levdev -o $@ tools/$@/
gy-801-dump:
	hare build -li2c -o $@ tools/$@/
.PHONY: evdev-dump-events uinput-pointer gy-801-dump
