use math;

export fn product(a: quaternion, b: quaternion) quaternion = {
	return (
		a.0 * b.0 - a.1 * b.1 - a.2 * b.2 - a.3 * b.3,
		a.0 * b.1 + a.1 * b.0 + a.2 * b.3 - a.3 * b.2,
		a.0 * b.2 - a.1 * b.3 + a.2 * b.0 + a.3 * b.1,
		a.0 * b.3 + a.1 * b.2 - a.2 * b.1 + a.3 * b.0 ,
	);
};

export fn norm2(a: quaternion) f64 = {
	return a.0 * a.0 + a.1 * a.1 + a.2 * a.2 + a.3 * a.3;
};

export fn norm(a: quaternion) f64 = {
	return math::sqrtf64(norm2(a));
};

export fn normalize(a: quaternion) quaternion = {
	const norm = norm(a);
	return (a.0 / norm, a.1 / norm, a.2 / norm, a.3 / norm);
};
