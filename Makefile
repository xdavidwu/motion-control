SENSORS ?= gy801
BINARIES = evdev-dump-events uinput-pointer sensors-dump pointerd pointerc motion-control buttonc

evdev-dump-events uinput-pointer:
	hare build -levdev -o $@ tools/$@/
sensors-dump pointerc:
	hare build -T +$(SENSORS) -o $@ tools/$@/
buttonc:
	hare build -o $@ tools/$@/
pointerd:
	hare build -levdev -o $@ cmd/$@/
motion-control:
	hare build -T +$(SENSORS) -o $@ cmd/$@/
.PHONY: $(BINARIES)
all: $(BINARIES)
clean:
	rm -f $(BINARIES)
