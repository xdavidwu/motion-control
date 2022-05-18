use math;

export fn slerp(a: quaternion, b: quaternion, t: f64) quaternion = {
	const cos_theta = a.0 * b.0 + a.1 * b.1 + a.2 * b.2 + a.3 * b.3;
	const theta = math::acosf64(cos_theta);
	const sin_theta = math::sinf64(theta);
	const a_scale = math::sinf64((1.0 - t) * theta) / sin_theta;
	const b_scale = math::sinf64(t * theta) / sin_theta;

	return if (cos_theta < 0.0) (
		a.0 * a_scale - b.0 * b_scale,
		a.1 * a_scale - b.1 * b_scale,
		a.2 * a_scale - b.2 * b_scale,
		a.3 * a_scale - b.3 * b_scale,
	) else (
		a.0 * a_scale + b.0 * b_scale,
		a.1 * a_scale + b.1 * b_scale,
		a.2 * a_scale + b.2 * b_scale,
		a.3 * a_scale + b.3 * b_scale,
	);
};
