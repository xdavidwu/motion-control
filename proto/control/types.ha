export def DEFAULT_PORT: u16	= 0x519;

export type code = enum u8 {
	RELATIVE_MOVEMENT	= 0,
	KEY_PRESSED	= 1,
	KEY_RELEASED	= 2,
};

export type key = enum u8 {
	BTN_LEFT	= 0,
	BTN_RIGHT	= 1,
};

export type request = union {
	struct {
		code: u8,
		union {
			struct {
				x: i8,
				y: i8,
			},
			key: u8,
		},
	},
	bytes: [3]u8,
};
