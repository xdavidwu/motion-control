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

def USB_VENDOR_ID_NINTENDO: int = 0x057e;

def USB_DEVICE_ID_NINTENTO_PROCON: int		= 0x2009;
def USB_DEVICE_ID_NINTENTO_CHRGGRIP: int	= 0x200e;
def USB_DEVICE_ID_NINTENTO_JOYCONL: int		= 0x2006;
def USB_DEVICE_ID_NINTENTO_JOYCONR: int		= 0x2007;

export type joycon = *joycon_impl;
