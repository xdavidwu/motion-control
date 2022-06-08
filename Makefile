evdev-dump-events uinput-pointer:
	hare build -levdev -o $@ tools/$@/
gy-801-dump pointerc buttonc:
	hare build -o $@ tools/$@/
pointerd:
	hare build -levdev -o $@ cmd/$@/
motion-control:
	hare build -o $@ cmd/$@/
.PHONY: evdev-dump-events uinput-pointer gy-801-dump pointerd pointerc motion-control buttonc
