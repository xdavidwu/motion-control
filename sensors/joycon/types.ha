use evdev;
use io;

export type sample = struct {
	timestamp: u32,
	gyroscope: (f64, f64, f64),
	accelerometer: (f64, f64, f64),
};

export type joycon_impl = struct {
	fd: io::file,
	dev: evdev::libevdev,
	state: sample,
	read: u8,
};

def READ_X: u8	= 1;
def READ_Y: u8	= 1 << 1;
def READ_Z: u8	= 1 << 2;
def READ_RX: u8	= 1 << 3;
def READ_RY: u8	= 1 << 4;
def READ_RZ: u8	= 1 << 5;
def READ_FULL: u8	 = (1 << 6) - 1;

export type joycon = *joycon_impl;
