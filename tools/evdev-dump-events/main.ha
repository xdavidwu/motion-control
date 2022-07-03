use errors;
use evdev;
use fmt;
use fs;
use io;
use os;
use strconv;

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
	case let err: errors::error =>
		fmt::fatalf("Failed to init libevdev: {}", errors::strerror(err));
	};

	fmt::printfln("Input device name: {}", evdev::get_name(evdev))!;

	for (true) {
		let ev = evdev::input_event {...};
		match (evdev::next_event(evdev, evdev::read_flag::NORMAL, &ev)) {
		case let r: evdev::read_status =>
			switch (r) {
			case evdev::read_status::SUCCESS =>
				yield;
			case evdev::read_status::SYNC =>
				continue;
			};
		case let err: errors::error =>
			match (err) {
			case errors::again =>
				continue;
			case =>
				fmt::fatalf("Failed to get event: {}", errors::strerror(err));
			};
		};
		match (evdev::event_type_get_name(ev._type)) {
		case errors::invalid =>
			fmt::printf("{:-13}", ev._type)!;
		case let s: const str =>
			fmt::printf("{:-13}", s)!;
		};
		match (evdev::event_code_get_name(ev._type, ev.code)) {
		case errors::invalid =>
			fmt::printf(" {:-29}", ev.code)!;
		case let s: const str =>
			fmt::printf(" {:-29}", s)!;
		};
		fmt::printfln(" {}", ev.value)!;
	};
};
