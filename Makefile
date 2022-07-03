SENSORS ?= gy801
HEADERS_PREFIX ?= /usr/include
BINARIES = evdev-dump-events uinput-pointer sensors-dump pointerd pointerc motion-control buttonc

event-codes:
	hare build -o $@ aux/$@/
evdev/codes.ha: event-codes
	./event-codes <$(HEADERS_PREFIX)/linux/input-event-codes.h >$@

evdev-dump-events uinput-pointer: evdev/codes.ha
	hare build -levdev -o $@ tools/$@/
sensors-dump pointerc:
	hare build -T +$(SENSORS) -o $@ tools/$@/
buttonc:
	hare build -o $@ tools/$@/
pointerd: evdev/codes.ha
	hare build -levdev -o $@ cmd/$@/
motion-control:
	hare build -T +$(SENSORS) -o $@ cmd/$@/
.PHONY: $(BINARIES)
all: $(BINARIES)
clean:
	rm -f event-codes evdev/codes.ha $(BINARIES)
