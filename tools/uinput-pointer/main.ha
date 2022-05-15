use evdev;
use evdev::uinput;
use fmt;
use rt;
use time;

export fn main() void = {
	const evdev = evdev::new();
	defer evdev::destroy(evdev);
	evdev::set_name(evdev, "uinput pointer");
	evdev::enable_event_type(evdev, evdev::EV_REL)!;
	evdev::enable_event_code(evdev, evdev::EV_REL, evdev::REL_X, null)!;
	evdev::enable_event_code(evdev, evdev::EV_REL, evdev::REL_Y, null)!;
	evdev::enable_event_type(evdev, evdev::EV_KEY)!;
	evdev::enable_event_code(evdev, evdev::EV_KEY, evdev::BTN_LEFT, null)!;
	evdev::enable_event_code(evdev, evdev::EV_KEY, evdev::BTN_MIDDLE, null)!;
	evdev::enable_event_code(evdev, evdev::EV_KEY, evdev::BTN_RIGHT, null)!;

	const uinput = match (evdev::uinput::create_from_device(evdev, evdev::uinput::OPEN_MANAGED)) {
	case let uinput: evdev::uinput::uinput =>
		yield uinput;
	case let err: rt::errno =>
		fmt::fatalf("Failed to create uinput dev: {}", rt::strerror(err));
	};
	defer evdev::uinput::destroy(uinput);

	for (let i = 0; i < 100; i += 1) {
		evdev::uinput::write_event(uinput, evdev::EV_REL, evdev::REL_X, 1)!;
		evdev::uinput::write_event(uinput, evdev::EV_SYN, evdev::SYN_REPORT, 0)!;
		time::sleep(10 * time::MILLISECOND);
	};
};
