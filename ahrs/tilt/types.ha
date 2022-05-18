use math::quaternion;

export type tilt_impl = struct {
	neutral: quaternion::quaternion,
};

export type tilt = *tilt_impl;
