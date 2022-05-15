use io;
use rt;
use strings;

export fn new_from_fd(fd: io::file) (rt::errno | libevdev) = {
	let handle = null: libevdev;
	const r = c_libevdev_new_from_fd(fd, &handle);
	if (r < 0) {
		return (-r): rt::errno;
	};
	return handle;
};

export fn get_name(dev: libevdev) const str = {
	return strings::fromc(c_libevdev_get_name(dev));
};

export fn next_event(dev: libevdev, flags: uint) (rt::errno | input_event) = {
	let ev = input_event { ... };
	const r = c_libevdev_next_event(dev, flags, &ev);
	if (r < 0) {
		return (-r): rt::errno;
	};
	return ev;
};

@symbol("libevdev_new_from_fd") fn c_libevdev_new_from_fd(fd: int, dev: *libevdev) int;
@symbol("libevdev_get_name") fn c_libevdev_get_name(dev: libevdev) *const char;
@symbol("libevdev_next_event") fn c_libevdev_next_event(dev: libevdev, flags: uint, ev: *input_event) int;
