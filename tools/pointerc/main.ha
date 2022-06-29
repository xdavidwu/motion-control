use fmt;
use net;
use net::ip;
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
	if (len(os::args) > 5 || len(os::args) < 4) {
		fmt::fatalf("Usage: {} addr port (x y | left | right)", os::args[0]);
	};
	const addr = match (ip::parse(os::args[1])) {
	case let addr: ip::addr =>
		yield addr;
	case ip::invalid =>
		fmt::fatalf("Invalid address {}", os::args[1]);
	};
	const port = match (strconv::stou16(os::args[2])) {
	case let port: u16 =>
		yield port;
	case =>
		fmt::fatalf("Invalid port {}", os::args[2]);
	};

	const sock = match (udp::connect(addr, port)) {
	case let s: net::socket =>
		yield s;
	case let err: net::error =>
		fmt::fatalf("Cannot connect() {}:{}: {}", ip::string(addr), port, net::strerror(err));
	};
	defer net::close(sock)!;

	let buf = control::request {...};

	if (strings::compare(os::args[3], "left") == 0) {
		buf.code = control::code::KEY_PRESSED;
		buf.key = control::key::BTN_LEFT;
		send(sock, buf.bytes);
		buf.code = control::code::KEY_RELEASED;
		send(sock, buf.bytes);
	} else if (strings::compare(os::args[3], "right") == 0) {
		buf.code = control::code::KEY_PRESSED;
		buf.key = control::key::BTN_RIGHT;
		send(sock, buf.bytes);
		buf.code = control::code::KEY_RELEASED;
		send(sock, buf.bytes);
	} else {
		buf.code = control::code::RELATIVE_MOVEMENT;
		buf.x = match (strconv::stoi8(os::args[3])) {
		case let n: i8 =>
			yield n;
		case =>
			fmt::fatalf("Invalid x {}", os::args[3]);
		};
		buf.y = match (strconv::stoi8(os::args[4])) {
		case let n: i8 =>
			yield n;
		case =>
			fmt::fatalf("Invalid y {}", os::args[4]);
		};
		send(sock, buf.bytes);
	};
	return 0;
};
