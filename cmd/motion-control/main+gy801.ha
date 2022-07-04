use ahrs::complementary;
use errors;
use fmt;
use fs;
use getopt;
use io;
use linux::timerfd;
use math;
use net;
use net::dial;
use net::udp;
use os;
use proto::control;
use sensors::ADXL345;
use sensors::L3G4200D;
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
		"bus address",
	];
	const cmd = getopt::parse(os::args, help...);
	defer getopt::finish(&cmd);
	if (len(cmd.args) != 2) {
		getopt::printusage(os::stderr, os::args[0], help);
		os::exit(-1);
	};
	const bus = match (strconv::stoi(cmd.args[0])) {
	case let bus: int =>
		yield bus;
	case =>
		fmt::fatal("bus should be a integer");
	};

	const buf = control::request {
		code = control::code::RELATIVE_MOVEMENT,
		...,
	};

	const sock = match (dial::dial("udp", cmd.args[1], strconv::u16tos(control::DEFAULT_PORT))) {
	case let s: net::socket =>
		yield s;
	case let err: net::error =>
		fmt::fatalf("Cannot dial() {}: {}", cmd.args[1], net::strerror(err));
	};
	defer net::close(sock)!;

	const ADXL345 = match (ADXL345::new(bus)) {
	case let ADXL345: ADXL345::ADXL345 =>
		yield ADXL345;
	case let err: fs::error =>
		fmt::fatalf("Cannot open i2c device: {}", fs::strerror(err));
	case let err: errors::error =>
		fmt::fatalf("Cannot ioctl i2c device: {}", errors::strerror(err));
	};
	defer ADXL345::destroy(ADXL345);

	const L3G4200D = match (L3G4200D::new(bus)) {
	case let L3G4200D: L3G4200D::L3G4200D =>
		yield L3G4200D;
	case let err: fs::error =>
		fmt::fatalf("Cannot open i2c device: {}", fs::strerror(err));
	case let err: errors::error =>
		fmt::fatalf("Cannot ioctl i2c device: {}", errors::strerror(err));
	};
	defer L3G4200D::destroy(L3G4200D);

	ADXL345::init(ADXL345)!;
	L3G4200D::init(L3G4200D)!;

	const fd = timerfd::new(time::clock::MONOTONIC, 0)!;
	defer io::close(fd)!;
	timerfd::set(fd, (10 * time::MILLISECOND): timerfd::interval, 0)!;
	signal::handle(signal::SIGINT, &sigint, signal::flag::RESTART);
	signal::handle(signal::SIGUSR1, &sigusr1, signal::flag::RESTART);

	timerfd::read(fd)!;
	const acc_readings = ADXL345::read(ADXL345)!;
	let complementary = complementary::new(acc_readings, 0.02);

	for (let i = 0; global_state != state::EXIT; i += 1) {
		timerfd::read(fd)!;
		switch (global_state) {
		case state::NORMAL =>
			const gyro_readings = L3G4200D::read(L3G4200D)!;
			const acc_readings = ADXL345::read(ADXL345)!;
			let rps = (gyro_readings.0 / 180.0 * math::PI,
				gyro_readings.1 / 180.0 * math::PI,
				gyro_readings.2 / 180.0 * math::PI);
			complementary::update(complementary, rps, 0.01);
			complementary::update_accelerometer(complementary, acc_readings);

			let attitude = complementary::read_euler(complementary);
			buf.x = ((attitude.2 / math::PI * 180.0): int / 8): i8;
			buf.y = ((attitude.1 / math::PI * 180.0): int / 4): i8;
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
			const acc_readings = ADXL345::read(ADXL345)!;
			complementary = complementary::new(acc_readings, 0.02);
			global_state = state::NORMAL;
		case state::EXIT =>
			break;
		};
	};

	return 0;
};
