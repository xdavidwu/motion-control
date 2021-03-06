use errors;
use evdev;
use evdev::uinput;
use fmt;
use net;
use net::ip;
use net::udp;
use proto::control;
use rt;
use time;
use unix::signal;

let exit: bool	= false;

fn sigint(sig: int, info: *signal::siginfo, ucontext: *void) void = {
	exit = true;
};

fn protocol_key_to_event_code(key: u8) u16 = {
	switch (key) {
	case control::key::BTN_LEFT =>
		return evdev::BTN_LEFT;
	case control::key::BTN_RIGHT =>
		return evdev::BTN_RIGHT;
	case =>
		fmt::fatalf("Invalid key code {}", key);
	};
};

export fn main() void = {
	const evdev = evdev::new();
	defer evdev::destroy(evdev);
	evdev::set_name(evdev, "motion-control pointer");
	evdev::enable_event_type(evdev, evdev::EV_REL)!;
	evdev::enable_event_code(evdev, evdev::EV_REL, evdev::REL_X, null)!;
	evdev::enable_event_code(evdev, evdev::EV_REL, evdev::REL_Y, null)!;
	evdev::enable_event_type(evdev, evdev::EV_KEY)!;
	evdev::enable_event_code(evdev, evdev::EV_KEY, evdev::BTN_LEFT, null)!;
	evdev::enable_event_code(evdev, evdev::EV_KEY, evdev::BTN_MIDDLE, null)!;
	evdev::enable_event_code(evdev, evdev::EV_KEY, evdev::BTN_RIGHT, null)!;

	const uinput = match (uinput::create_from_device(evdev, uinput::OPEN_MANAGED)) {
	case let uinput: uinput::uinput =>
		yield uinput;
	case let err: errors::error =>
		fmt::fatalf("Failed to create uinput dev: {}", errors::strerror(err));
	};
	defer uinput::destroy(uinput);

	const addr = ip::ANY_V6, port = control::DEFAULT_PORT;
	const sock = match (udp::listen(addr, port)) {
	case let sock: net::socket =>
		yield sock;
	case let err: net::error =>
		fmt::fatalf("Failed to listen on {}:{}: {}",
			ip::string(addr), port, net::strerror(err));
	};
	defer net::close(sock)!;

	signal::handle(signal::SIGINT, &sigint);
	let buf = control::request {...};
	for (true) {
		const sz = match (udp::recvfrom(sock, buf.bytes, null, null)) {
		case let sz: size =>
			yield sz;
		case errors::interrupted =>
			break;
		case let err: net::error =>
			fmt::fatalf("recvfrom: {}", net::strerror(err));
		};
		if (sz != size(control::request)) {
			fmt::errorln("Unexpected read size")!;
			continue;
		};
		switch (buf.code) {
		case control::code::RELATIVE_MOVEMENT =>
			uinput::write_event(uinput, evdev::EV_REL, evdev::REL_X, buf.x)!;
			uinput::write_event(uinput, evdev::EV_REL, evdev::REL_Y, buf.y)!;
			uinput::write_event(uinput, evdev::EV_SYN, evdev::SYN_REPORT, 0)!;
		case control::code::KEY_PRESSED =>
			const code = protocol_key_to_event_code(buf.key);
			uinput::write_event(uinput, evdev::EV_KEY, code, 1)!;
			uinput::write_event(uinput, evdev::EV_SYN, evdev::SYN_REPORT, 0)!;
		case control::code::KEY_RELEASED =>
			const code = protocol_key_to_event_code(buf.key);
			uinput::write_event(uinput, evdev::EV_KEY, code, 0)!;
			uinput::write_event(uinput, evdev::EV_SYN, evdev::SYN_REPORT, 0)!;
		case =>
			fmt::errorfln("Unrecognized control code: {}", buf.code)!;
		};
	};
};
