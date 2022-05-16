def BLOCK_MAX: u8	= 32;

export type data = union {
	byte: u8,
	word: u16,
	block: [BLOCK_MAX + 2]u8,
};

type ioctl_data = struct {
	read_write: u8,
	command: u8,
	_size: u32,
	data: *data,
};

export def READ: u8	= 1;
export def WRITE: u8	= 0;

export def QUICK: u32	= 0;
export def BYTE: u32	= 1;
export def BYTE_DATA: u32	= 2;
export def WORD_DATA: u32	= 3;
export def PROC_CALL: u32	= 4;
export def BLOCK_DATA: u32	= 5;
export def I2C_BLOCK_BROKEN: u32	= 6;
export def BLOCK_PROC_CALL: u32	= 7;
export def I2C_BLOCK_DATA: u32	= 8;
