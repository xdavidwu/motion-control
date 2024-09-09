SENSORS ?= joycon
SENSORS_LIBS =
HEADERS_PREFIX ?= /usr/include
BINARIES = event-codes evdev-dump-events uinput-pointer sensors-dump pointerd pointerc motion-control buttonc squats

ifeq ($(SENSORS), joycon)
	SENSORS_LIBS = -levdev
endif

.PHONY: $(BINARIES)
all: $(BINARIES)

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
motion-control squats:
	hare build $(SENSORS_LIBS) -T +$(SENSORS) -o $@ cmd/$@/

clean:
	rm -f event-codes evdev/codes.ha $(BINARIES)
