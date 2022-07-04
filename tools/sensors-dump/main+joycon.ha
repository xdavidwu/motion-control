use ahrs::complementary;
use ahrs::tilt;
use ahrs::integration;
use errors;
use fmt;
use fmt;
use math;
use sensors::joycon;
use unix::signal;

let exit: bool	= false;

fn sigint(sig: int, info: *signal::siginfo, ucontext: *void) void = {
	exit = true;
};

export fn main() void = {
	const joycon = joycon::new(void)!;
	defer joycon::destroy(joycon);

	signal::handle(signal::SIGINT, &sigint, signal::flag::RESTART);

	const sample = joycon::next_sample(joycon)!;
	let prev_us = sample.timestamp;

	const acc_readings = sample.accelerometer;
	fmt::printfln("Neutral acc.: {} {} {} g", acc_readings.0, acc_readings.1, acc_readings.2)!;
	const integrator = integration::new();
	const tilt = tilt::new(acc_readings);
	const complementary = complementary::new(acc_readings, 0.02);

	for (let i = 0; !exit; i += 1) {
		const sample = joycon::next_sample(joycon)!;
		const gyro_readings = sample.gyroscope;
		const acc_readings = sample.accelerometer;
		let rps = (gyro_readings.0 / 180.0 * math::PI,
			gyro_readings.1 / 180.0 * math::PI,
			gyro_readings.2 / 180.0 * math::PI);
		const dt = (sample.timestamp - prev_us): f64 / 1000000.0;
		integration::update(integrator, rps, dt);
		complementary::update(complementary, rps, dt);
		complementary::update_accelerometer(complementary, acc_readings);
		prev_us = sample.timestamp;

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
