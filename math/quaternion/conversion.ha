use fmt;
use math;

// quarternion from axis-angle, angle is in radians
export fn from_axis_angle(axis: (f64, f64, f64), angle: f64) quaternion = {
	const angle = angle / 2.0f64;
	const s = math::sinf64(angle);
	return (math::cosf64(angle), axis.0 * s, axis.1 * s, axis.2 * s);
};

export fn to_euler(q: quaternion) (f64, f64, f64) = {
	return (
		math::atanf64(2.0 * (q.0 * q.1 + q.2 * q.3) / (1.0 - 2.0 * (q.1 * q.1 + q.2 * q.2))),
		math::asinf64(2.0 * (q.0 * q.2 - q.3 * q.1)),
		math::atanf64(2.0 * (q.0 * q.3 + q.1 * q.2) / (1.0 - 2.0 * (q.2 * q.2 + q.3 * q.3))),
	);
};

@test fn conversion() void = {
	let euler = (2.0 / 180.0 * math::PI, 3.0 / 180.0 * math::PI, 4.0 / 180.0 * math::PI);
	fmt::println(euler.0, euler.1, euler.2)!;
	let angle = math::sqrtf64(euler.0 * euler.0 + euler.1 * euler.1 + euler.2 * euler.2);
	let axis = (euler.0 / angle, euler.1 / angle, euler.2 / angle);
	let q = from_axis_angle(axis, angle);
	let res = to_euler(q);
	fmt::println(res.0, res.1, res.2)!;
};
