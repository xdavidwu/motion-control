use ahrs::complementary;
use errors;
use fmt;
use getopt;
use io;
use linux::timerfd;
use math;
use net;
use net::dial;
use net::udp;
use os;
use proto::control;
use rt;
use sensors::joycon;
use strconv;
use time;
use unix::signal;

type state = enum u8 {
	NORMAL,
	BLOCK,
	RESET,
	EXIT,
};

let global_state: state	= state::NORMAL;

fn sigint(sig: int, info: *signal::siginfo, ucontext: *void) void = {
	global_state = state::EXIT;
};

fn sigusr1(sig: int, info: *signal::siginfo, ucontext: *void) void = {
	switch (global_state) {
	case state::NORMAL =>
		fmt::println("Block")!;
		global_state = state::BLOCK;
	case state::BLOCK =>
		fmt::println("Reset")!;
		global_state = state::RESET;
	case state::RESET =>
		fmt::println("Reset is already pending")!;
	case state::EXIT =>
		fmt::println("Exit pending")!;
	};
};

export fn main() int = {
	const help: []getopt::help = [
		"control pointerd with motion",
		"address",
	];
	const cmd = getopt::parse(os::args, help...);
	defer getopt::finish(&cmd);
	if (len(cmd.args) != 1) {
		getopt::printusage(os::stderr, os::args[0], help);
		os::exit(-1);
	};

	const buf = control::request {
		code = control::code::RELATIVE_MOVEMENT,
		...,
	};

	const sock = match (dial::dial("udp", cmd.args[0], strconv::u16tos(control::DEFAULT_PORT))) {
	case let s: net::socket =>
		yield s;
	case let err: net::error =>
		fmt::fatalf("Cannot dial() {}: {}", cmd.args[0], net::strerror(err));
	};
	defer net::close(sock)!;

	const epoll = rt::epoll_create1(rt::EPOLL_CLOEXEC)!;
	defer io::close(epoll)!;

	const joycon = joycon::new(void)!;
	defer joycon::destroy(joycon);

	const joycon_epoll = rt::epoll_event {
		events = rt::EPOLLIN,
		data = rt::epoll_data {
			fd = joycon.fd,
		},
	};
	rt::epoll_ctl(epoll, rt::EPOLL_CTL_ADD, joycon.fd, &joycon_epoll)!;

	const fd = timerfd::new(time::clock::MONOTONIC, rt::O_NONBLOCK)!;
	defer io::close(fd)!;
	timerfd::set(fd, (10 * time::MILLISECOND): timerfd::interval, 0)!;
	const timer_epoll = rt::epoll_event {
		events = rt::EPOLLIN | rt::EPOLLET,
		data = rt::epoll_data {
			fd = fd,
		},
	};
	rt::epoll_ctl(epoll, rt::EPOLL_CTL_ADD, fd, &timer_epoll)!;

	signal::handle(signal::SIGINT, &sigint, signal::flag::RESTART);
	signal::handle(signal::SIGUSR1, &sigusr1, signal::flag::RESTART);

	const sample = joycon::next_sample(joycon)!;
	let prev_us = sample.timestamp;

	let complementary = complementary::new(sample.accelerometer, 0.02);

	let e = rt::epoll_event {...};
	for (global_state != state::EXIT) {
		match (rt::epoll_wait(epoll, &e, 1, -1)) {
		case let e: rt::errno =>
			switch (e) {
			case rt::EINTR =>
				break;
			case =>
				abort("Unexpected error");
			};
		case =>
			yield;
		};
		if (e.data.fd == fd) {
			timerfd::read(fd)!;
			switch (global_state) {
			case state::NORMAL =>
				let attitude = complementary::read_euler(complementary);
				buf.x = ((attitude.2 / math::PI * 180.0): int / 8): i8;
				buf.y = ((-attitude.1 / math::PI * 180.0): int / 4): i8;
				match (udp::send(sock, buf.bytes)) {
				case let err: net::error =>
					fmt::fatalf("Cannot send(): {}", net::strerror(err));
				case size =>
					yield;
				};
			case state::BLOCK =>
				yield;
			case state::RESET =>
				complementary::destroy(complementary);
				const sample = joycon::next_sample(joycon)!;
				complementary = complementary::new(sample.accelerometer, 0.02);
				global_state = state::NORMAL;
			case state::EXIT =>
				break;
			};
		} else if (e.data.fd == joycon.fd) {
			const sample = joycon::next_sample(joycon)!;
			const gyro_readings = sample.gyroscope;
			const acc_readings = sample.accelerometer;
			let rps = (gyro_readings.0 / 180.0 * math::PI,
				gyro_readings.1 / 180.0 * math::PI,
				gyro_readings.2 / 180.0 * math::PI);
			const dt = (sample.timestamp - prev_us): f64 / 1000000.0;
			complementary::update(complementary, rps, dt);
			complementary::update_accelerometer(complementary, acc_readings);
			prev_us = sample.timestamp;
		};
	};

	return 0;
};
