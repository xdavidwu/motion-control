export def DEFAULT_PORT: u16	= 0x519;

export type code = enum u8 {
	RELATIVE_MOVEMENT	= 0,
};

export type request = union {
	struct {
		code: u8,
		union {
			struct {
				x: i8,
				y: i8,
			},
		},
	},
	bytes: [3]u8,
};
