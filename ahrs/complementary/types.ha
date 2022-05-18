use ahrs::integration;
use ahrs::tilt;

export type complementary_impl = struct {
	alpha: f64,
	integration: integration::integration,
	tilt: tilt::tilt,
};

export type complementary = *complementary_impl;
