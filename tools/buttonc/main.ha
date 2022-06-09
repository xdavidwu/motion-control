use fmt;
use getopt;
use io;
use net;
use net::ip;
use net::udp;
use os;
use proto::control;
use strconv;
use unix::tty;

fn send(sock: io::file, bytes: []u8) void = {
	match (udp::send(sock, bytes)) {
	case let err: net::error =>
		fmt::fatalf("Cannot send(): {}", net::strerror(err));
	case size =>
		yield;
	};
};

export fn main() int = {
	const help: []getopt::help = [
		"control pointerd with buttons",
		"addr port",
	];
	const cmd = getopt::parse(os::args, help...);
	defer getopt::finish(&cmd);
	if (len(cmd.args) != 2) {
		getopt::printusage(os::stderr, os::args[0], help);
		os::exit(-1);
	};
	const addr = match (ip::parse(cmd.args[0])) {
	case let addr: ip::addr =>
		yield addr;
	case ip::invalid =>
		fmt::fatalf("Invalid address {}", cmd.args[0]);
	};
	const port = match (strconv::stou16(cmd.args[1])) {
	case let port: u16 =>
		yield port;
	case =>
		fmt::fatalf("Invalid port {}", cmd.args[1]);
	};

	const sock = match (udp::connect(addr, port)) {
	case let s: io::file =>
		yield s;
	case let err: net::error =>
		fmt::fatalf("Cannot connect() {}:{}: {}", ip::string(addr), port, net::strerror(err));
	};
	defer io::close(sock)!;

	let buf = control::request {...};

	const tty = tty::isatty(os::stdin_file);
	let termios: *tty::termios = &tty::termios {...};

	if (tty) {
		termios = &tty::termios_query(os::stdin_file)!;
		tty::makeraw(termios)!;
	};
	if (tty) defer tty::termios_restore(termios);

	for (true) {
		let i: []u8 = [0];
		match (io::read(os::stdin_file, i)) {
		case size =>
			yield;
		case io::EOF =>
			break;
		case let err: io::error =>
			fmt::fatalf("Cannot read(): {}", io::strerror(err));
		};
		switch (i[0]) {
		case 'A' =>
			buf.code = control::code::KEY_PRESSED;
			buf.key = control::key::BTN_LEFT;
			send(sock, buf.bytes);
		case 'a' =>
			buf.code = control::code::KEY_RELEASED;
			buf.key = control::key::BTN_LEFT;
			send(sock, buf.bytes);
		case 'B' =>
			buf.code = control::code::KEY_PRESSED;
			buf.key = control::key::BTN_RIGHT;
			send(sock, buf.bytes);
		case 'b' =>
			buf.code = control::code::KEY_RELEASED;
			buf.key = control::key::BTN_RIGHT;
			send(sock, buf.bytes);
		case 4 => // EOT
			break;
		};
	};

	return 0;
};
