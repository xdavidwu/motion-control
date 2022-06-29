use ahrs::complementary;
use ahrs::tilt;
use ahrs::integration;
use fmt;
use fs;
use io;
use os;
use rt;
use linux::timerfd;
use math;
use sensors::ADXL345;
use sensors::L3G4200D;
use strconv;
use time;
use unix::signal;

let exit: bool	= false;

fn sigint(sig: int, info: *signal::siginfo, ucontext: *void) void = {
	exit = true;
};

export fn main() void = {
	if (len(os::args) != 2) {
		fmt::fatalf("Usage: {} bus", os::args[0]);
	};
	const bus = match (strconv::stoi(os::args[1])) {
	case let bus: int =>
		yield bus;
	case =>
		fmt::fatal("bus should be a integer");
	};

	const ADXL345 = match (ADXL345::new(bus)) {
	case let ADXL345: ADXL345::ADXL345 =>
		yield ADXL345;
	case let err: fs::error =>
		fmt::fatalf("Cannot open i2c device: {}", fs::strerror(err));
	case let err: rt::errno =>
		fmt::fatalf("Cannot ioctl i2c device: {}", rt::strerror(err));
	};
	defer ADXL345::destroy(ADXL345);

	const L3G4200D = match (L3G4200D::new(bus)) {
	case let L3G4200D: L3G4200D::L3G4200D =>
		yield L3G4200D;
	case let err: fs::error =>
		fmt::fatalf("Cannot open i2c device: {}", fs::strerror(err));
	case let err: rt::errno =>
		fmt::fatalf("Cannot ioctl i2c device: {}", rt::strerror(err));
	};
	defer L3G4200D::destroy(L3G4200D);

	ADXL345::init(ADXL345)!;
	L3G4200D::init(L3G4200D)!;

	const fd = timerfd::new(time::clock::MONOTONIC, 0)!;
	defer io::close(fd)!;
	timerfd::set(fd, (10 * time::MILLISECOND): timerfd::interval, 0)!;
	signal::handle(signal::SIGINT, &sigint, signal::flag::RESTART);
	const integrator = integration::new();

	timerfd::read(fd)!;
	const acc_readings = ADXL345::read(ADXL345)!;
	fmt::printfln("Neutral acc.: {} {} {} g", acc_readings.0, acc_readings.1, acc_readings.2)!;
	const tilt = tilt::new(acc_readings);
	const complementary = complementary::new(acc_readings, 0.02);

	for (let i = 0; !exit; i += 1) {
		timerfd::read(fd)!;
		const gyro_readings = L3G4200D::read(L3G4200D)!;
		const acc_readings = ADXL345::read(ADXL345)!;
		let rps = (gyro_readings.0 / 180.0 * math::PI,
			gyro_readings.1 / 180.0 * math::PI,
			gyro_readings.2 / 180.0 * math::PI);
		integration::update(integrator, rps, 0.01);
		complementary::update(complementary, rps, 0.01);
		complementary::update_accelerometer(complementary, acc_readings);

		if (i % 50 == 0) {
			let attitude = integration::read_euler(integrator);
			let tilt_attitude = tilt::estimate_euler(tilt, acc_readings);
			let complementary_attitude = complementary::read_euler(complementary);

			fmt::printfln("Accelerometer: {} {} {} g",
				acc_readings.0, acc_readings.1, acc_readings.2)!;
			fmt::printfln("Gyroscope: {} {} {} dps",
				gyro_readings.0, gyro_readings.1, gyro_readings.2)!;
			fmt::printfln("Attitude: {} {} {} deg",
				attitude.0 / math::PI * 180.0,
				attitude.1 / math::PI * 180.0,
				attitude.2 / math::PI * 180.0)!;
			fmt::printfln("Attitude (tilt): {} {} {} deg",
				tilt_attitude.0 / math::PI * 180.0,
				tilt_attitude.1 / math::PI * 180.0,
				tilt_attitude.2 / math::PI * 180.0)!;
			fmt::printfln("Attitude (complementary): {} {} {} deg",
				complementary_attitude.0 / math::PI * 180.0,
				complementary_attitude.1 / math::PI * 180.0,
				complementary_attitude.2 / math::PI * 180.0)!;
		};
	};
};
