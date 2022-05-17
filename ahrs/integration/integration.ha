use math;
use math::quaternion;

export fn new() integration = {
	return alloc(integration_impl {
		q = (1.0, 0.0, 0.0, 0.0),
	});
};

export fn update(integration: integration, readings: (f64, f64, f64), dt: f64) void = {
	let angle = math::sqrtf64(readings.0 * readings.0
		+ readings.1 * readings.1 + readings.2 * readings.2);
	let axis = (readings.0 / angle, readings.1 / angle, readings.2 / angle);
	let q = quaternion::from_axis_angle(axis, angle * dt);
	integration.q = quaternion::product(integration.q, q);
};

export fn read_euler(integration: integration) (f64, f64, f64) = {
	return quaternion::to_euler(integration.q);
};

export fn destroy(integration: integration) void = {
	free(integration);
};
