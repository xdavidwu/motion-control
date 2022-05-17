use math::quaternion;

export type integration_impl = struct {
	q: quaternion::quaternion,
};

export type integration = *integration_impl;
