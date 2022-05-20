use ahrs::integration;
use ahrs::tilt;
use math::quaternion;

export fn new(neutral: (f64, f64, f64), alpha: f64) complementary = {
	return alloc(complementary_impl {
		alpha = alpha,
		integration = integration::new(),
		tilt = tilt::new(neutral),
	});
};

export fn update(complementary: complementary, readings: (f64, f64, f64), dt: f64) void =
	integration::update(complementary.integration, readings, dt);

export fn read_euler(complementary: complementary) (f64, f64, f64) =
	integration::read_euler(complementary.integration);

export fn update_accelerometer(complementary: complementary, readings: (f64, f64, f64)) void = {
	let accel = quaternion::to_euler(tilt::estimate(complementary.tilt, readings));
	let orig = quaternion::to_euler(complementary.integration.q);
	let qc = quaternion::from_euler((accel.0, accel.1, orig.2));
	complementary.integration.q = quaternion::normalize(quaternion::slerp(
		complementary.integration.q,
		qc,
		complementary.alpha));
};

export fn destroy(complementary: complementary) void = {
	integration::destroy(complementary.integration);
	tilt::destroy(complementary.tilt);
	free(complementary);
};
