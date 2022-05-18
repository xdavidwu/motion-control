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
