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

export fn from_euler(v: (f64, f64, f64)) quaternion = {
	const s0 = math::sinf64(v.0 / 2.0);
	const c0 = math::cosf64(v.0 / 2.0);
	const s1 = math::sinf64(v.1 / 2.0);
	const c1 = math::cosf64(v.1 / 2.0);
	const s2 = math::sinf64(v.2 / 2.0);
	const c2 = math::cosf64(v.2 / 2.0);
	return (
		c0 * c1 * c2 + s0 * s1 * s2,
		s0 * c1 * c2 - c0 * s1 * s2,
		c0 * s1 * c2 + s0 * c1 * s2,
		c0 * c1 * s2 - s0 * s1 * c2,
	);
};
