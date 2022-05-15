use rt;

export type libevdev = *void;

export type input_event = struct {
	time:	rt::timeval,
	_type:	u16,
	code:	u16,
	value:	i32,
};

export def READ_FLAG_NORMAL: uint	= 2;
