use evdev;
use fmt;
use fs;
use io;
use rt;
use os;

export fn main() void = {
	if (len(os::args) != 2) {
		fmt::fatalf("Usage: {} DEVICE", os::args[0]);
	};
	const file = match (os::open(os::args[1], fs::flags::RDONLY | fs::flags::NONBLOCK)) {
	case let file: io::file =>
		yield file;
	case let err: fs::error =>
		fmt::fatalf("Cannot open {}: {}", os::args[1], fs::strerror(err));
	};

	const evdev = match (evdev::new_from_fd(file)) {
	case let evdev: evdev::libevdev =>
		yield evdev;
	case let err: rt::errno =>
		fmt::fatalf("Failed to init libevdev: {}", rt::strerror(err));
	};

	fmt::printfln("Input device name: {}", evdev::get_name(evdev))!;

	for (true) {
		let ev = match (evdev::next_event(evdev, evdev::READ_FLAG_NORMAL)) {
		case let ev: evdev::input_event =>
			yield ev;
		case let err: rt::errno =>
			switch (err) {
			case rt::EAGAIN =>
				continue;
			case =>
				fmt::fatalf("Failed to get event: {}", rt::strerror(err));
			};
		};
		fmt::printfln("event {} {} {}", ev._type, ev.code, ev.value)!;
	};
};
