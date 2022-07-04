use fmt;
use net;
use net::dial;
use net::udp;
use os;
use proto::control;
use strconv;
use strings;
use time;

fn send(sock: net::socket, bytes: []u8) void = {
	match (udp::send(sock, bytes)) {
	case let err: net::error =>
		fmt::fatalf("Cannot send(): {}", net::strerror(err));
	case size =>
		yield;
	};
};

export fn main() int = {
	if (len(os::args) > 4 || len(os::args) < 3) {
		fmt::fatalf("Usage: {} address (x y | left | right)", os::args[0]);
	};

	const sock = match (dial::dial("udp", os::args[1], strconv::u16tos(control::DEFAULT_PORT))) {
	case let s: net::socket =>
		yield s;
	case let err: net::error =>
		fmt::fatalf("Cannot dial() {}: {}", os::args[1], net::strerror(err));
	};
	defer net::close(sock)!;

	let buf = control::request {...};

	if (strings::compare(os::args[2], "left") == 0) {
		buf.code = control::code::KEY_PRESSED;
		buf.key = control::key::BTN_LEFT;
		send(sock, buf.bytes);
		buf.code = control::code::KEY_RELEASED;
		send(sock, buf.bytes);
	} else if (strings::compare(os::args[2], "right") == 0) {
		buf.code = control::code::KEY_PRESSED;
		buf.key = control::key::BTN_RIGHT;
		send(sock, buf.bytes);
		buf.code = control::code::KEY_RELEASED;
		send(sock, buf.bytes);
	} else {
		buf.code = control::code::RELATIVE_MOVEMENT;
		buf.x = match (strconv::stoi8(os::args[2])) {
		case let n: i8 =>
			yield n;
		case =>
			fmt::fatalf("Invalid x {}", os::args[2]);
		};
		buf.y = match (strconv::stoi8(os::args[3])) {
		case let n: i8 =>
			yield n;
		case =>
			fmt::fatalf("Invalid y {}", os::args[3]);
		};
		send(sock, buf.bytes);
	};
	return 0;
};
