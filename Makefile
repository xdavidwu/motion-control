SENSORS ?= gy801
SENSORS_LIBS =
HEADERS_PREFIX ?= /usr/include
BINARIES = evdev-dump-events uinput-pointer sensors-dump pointerd pointerc motion-control buttonc

ifeq ($(SENSORS), joycon)
	SENSORS_LIBS = -levdev
endif

event-codes:
	hare build -o $@ aux/$@/
evdev/codes.ha: event-codes
	./event-codes <$(HEADERS_PREFIX)/linux/input-event-codes.h >$@

evdev-dump-events uinput-pointer: evdev/codes.ha
	hare build -levdev -o $@ tools/$@/
sensors-dump:
	hare build $(SENSORS_LIBS) -T +$(SENSORS) -o $@ tools/$@/
buttonc pointerc:
	hare build -o $@ tools/$@/
pointerd: evdev/codes.ha
	hare build -levdev -o $@ cmd/$@/
motion-control:
	hare build $(SENSORS_LIBS) -T +$(SENSORS) -o $@ cmd/$@/
.PHONY: $(BINARIES)
all: $(BINARIES)
clean:
	rm -f event-codes evdev/codes.ha $(BINARIES)
