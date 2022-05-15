use evdev;
use io;
use rt;

export fn create_from_device(dev: evdev::libevdev, fd: io::file)
			(uinput | rt::errno) = {
	let handle = null: uinput;
	const r = c_libevdev_uinput_create_from_device(dev, fd: int, &handle);
	if (r < 0) {
		return (-r): rt::errno;
	};
	return handle;
};

export fn write_event(uinput_dev: uinput, event_type: uint, code: uint, value: int)
		(void | rt::errno) = {
	const r = c_libevdev_uinput_write_event(uinput_dev, event_type, code, value);
	if (r < 0) {
		return (-r): rt::errno;
	};
};

@symbol("libevdev_uinput_create_from_device") fn c_libevdev_uinput_create_from_device(
	dev: evdev::libevdev, uinput_fd: int, uinput_dev: *uinput) int;
export @symbol("libevdev_uinput_destroy") fn destroy(dev: uinput) void;
@symbol("libevdev_uinput_write_event") fn c_libevdev_uinput_write_event(
	uinput_dev: uinput, etype: uint, code: uint, value: int) int;
