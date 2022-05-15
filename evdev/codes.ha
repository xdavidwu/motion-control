export def EV_SYN: u16	= 0x00;
export def EV_KEY: u16	= 0x01;
export def EV_REL: u16	= 0x02;
export def EV_ABS: u16	= 0x03;
export def EV_MSC: u16	= 0x04;
export def EV_SW: u16	= 0x05;
export def EV_LED: u16	= 0x11;
export def EV_SND: u16	= 0x12;
export def EV_REP: u16	= 0x14;
export def EV_FF: u16	= 0x15;
export def EV_PWR: u16	= 0x16;
export def EV_FF_STATUS: u16	= 0x17;
export def EV_MAX: u16	= 0x1f;
export def EV_CNT: u16	= EV_MAX + 1;

export def SYN_REPORT: u16	= 0;
export def SYN_CONFIG: u16	= 1;
export def SYN_MT_REPORT: u16	= 2;
export def SYN_DROPPED: u16	= 3;
export def SYN_MAX: u16	= 0xf;
export def SYN_CNT: u16	= SYN_MAX + 1;

export def BTN_LEFT: u16	= 0x110;
export def BTN_RIGHT: u16	= 0x111;
export def BTN_MIDDLE: u16	= 0x112;

export def REL_X: u16	= 0x00;
export def REL_Y: u16	= 0x01;
export def REL_Z: u16	= 0x02;
