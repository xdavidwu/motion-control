use rt;

export type libevdev = *void;

export type input_event = struct {
	time:	rt::timeval,
	_type:	u16,
	code:	u16,
	value:	i32,
};

export type unknown_error = !void;

export type read_status = enum int {
	SUCCESS	= 0,
	SYNC	= 1,
};

export type read_flag = enum uint {
	SYNC	= 1,
	NORMAL	= 2,
	FORCE_SYNC	= 4,
	BLOCKING	= 8,
};
