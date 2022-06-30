use errors;
use io;
use rt;
use strings;

export fn new_from_fd(fd: io::file) (errors::error | libevdev) = {
	let handle = null: libevdev;
	const r = c_libevdev_new_from_fd(fd, &handle);
	if (r < 0) {
		return errors::errno(-r);
	};
	return handle;
};

export fn get_name(dev: libevdev) const str = {
	return strings::fromc(c_libevdev_get_name(dev));
};

export fn set_name(dev: libevdev, name: str) void = {
	const cstr = strings::to_c(name);
	defer free(cstr);
	c_libevdev_set_name(dev, cstr);
};

export fn next_event(dev: libevdev, flags: uint) (errors::error | input_event) = {
	let ev = input_event { ... };
	const r = c_libevdev_next_event(dev, flags, &ev);
	if (r < 0) {
		return errors::errno(-r);
	};
	return ev;
};

export fn enable_event_type(dev: libevdev, event_type: uint) (void | unknown_error) = {
	return if (c_libevdev_enable_event_type(dev, event_type) != 0) unknown_error else void;
};

export fn enable_event_code(dev: libevdev, event_type: uint, code: uint,
		data: nullable *void) (void | unknown_error) = {
	// TODO: wrap data with tagged union?
	return if (c_libevdev_enable_event_code(dev, event_type, code, data) != 0)
		unknown_error else void;
};

export fn event_type_get_name(_type: u16) (const str | errors::invalid) =
	match (c_libevdev_event_type_get_name(_type)) {
	case null =>
		return errors::invalid;
	case let s: *const char =>
		return strings::fromc(s);
	};

export fn event_code_get_name(_type: u16, code: u16) (const str | errors::invalid) =
	match (c_libevdev_event_code_get_name(_type, code)) {
	case null =>
		return errors::invalid;
	case let s: *const char =>
		return strings::fromc(s);
	};

export @symbol("libevdev_new") fn new() libevdev;
export @symbol("libevdev_free") fn destroy(dev: libevdev) void;

@symbol("libevdev_new_from_fd") fn c_libevdev_new_from_fd(fd: int, dev: *libevdev) int;
@symbol("libevdev_get_name") fn c_libevdev_get_name(dev: libevdev) *const char;
@symbol("libevdev_set_name") fn c_libevdev_set_name(dev: libevdev, name: *const char) void;
@symbol("libevdev_next_event") fn c_libevdev_next_event(dev: libevdev,
	flags: uint, ev: *input_event) int;
@symbol("libevdev_enable_event_type") fn c_libevdev_enable_event_type(
	dev: libevdev, etype: uint) int;
@symbol("libevdev_enable_event_code") fn c_libevdev_enable_event_code(
	dev: libevdev, etype: uint, code: uint, data: nullable *void) int;
@symbol("libevdev_event_type_get_name") fn c_libevdev_event_type_get_name(_type: uint) nullable *const char;
@symbol("libevdev_event_code_get_name") fn c_libevdev_event_code_get_name(_type: uint, code: uint) nullable *const char;
