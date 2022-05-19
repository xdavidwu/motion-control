use fmt;
use io;
use net;
use net::ip;
use net::udp;
use os;
use proto::control;
use strconv;

export fn main() int = {
	if (len(os::args) != 5) {
		fmt::fatalf("Usage: {} addr port x y", os::args[0]);
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
	const x = match (strconv::stoi8(os::args[3])) {
	case let n: i8 =>
		yield n;
	case =>
		fmt::fatalf("Invalid x {}", os::args[3]);
	};
	const y = match (strconv::stoi8(os::args[4])) {
	case let n: i8 =>
		yield n;
	case =>
		fmt::fatalf("Invalid y {}", os::args[4]);
	};

	const buf = control::request {
		code = control::code::RELATIVE_MOVEMENT,
		x = x,
		y = y,
	};

	const sock = match (udp::connect(addr, port)) {
	case let s: io::file =>
		yield s;
	case let err: net::error =>
		fmt::fatalf("Cannot connect() {}:{}: {}", ip::string(addr), port, net::strerror(err));
	};
	defer io::close(sock)!;

	match (udp::send(sock, buf.bytes)) {
	case let err: net::error =>
		fmt::fatalf("Cannot send(): {}", net::strerror(err));
	case size =>
		yield;
	};
	return 0;
};
