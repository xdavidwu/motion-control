use math;
use math::quaternion;

export fn new(neutral: (f64, f64, f64)) tilt = {
	const n = quaternion::normalize((0.0, neutral.0, neutral.1, neutral.2));
	return alloc(tilt_impl {
		neutral = n,
	});
};

export fn estimate(tilt: tilt, readings: (f64, f64, f64)) quaternion::quaternion = {
	// neutral = q r q^(-1), find q
	let r = quaternion::normalize((0.0, readings.0, readings.1, readings.2));
	let dot = tilt.neutral.1 * r.1  + tilt.neutral.2 * r.2 + tilt.neutral.3 * r.3;
	if (dot > 1f64) {
		dot = 1f64;
	};
	if (dot < -1f64) {
		dot = -1f64;
	};
	const angle = math::acosf64(dot);
	const axis = (
		r.2 * tilt.neutral.3 - r.3 * tilt.neutral.2,
		r.3 * tilt.neutral.1 - r.1 * tilt.neutral.3,
		r.1 * tilt.neutral.2 - r.2 * tilt.neutral.1,
	);
	return quaternion::from_axis_angle(axis, angle);
};

export fn estimate_euler(tilt: tilt, readings: (f64, f64, f64)) (f64, f64, f64) = {
	return quaternion::to_euler(estimate(tilt, readings));
};

export fn destroy(tilt: tilt) void = {
	free(tilt);
};
