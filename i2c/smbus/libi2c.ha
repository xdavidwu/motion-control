use i2c;
use io;
use rt;

export fn access(file: io::file, read_write: u8, command: u8, _size: u32, data: *data)
		(int | rt::errno) = {
	const args = ioctl_data {
		read_write = read_write,
		command = command,
		_size = _size,
		data = data,
	};
	return rt::ioctl(file: int, i2c::I2C_SMBUS, &args);
};

export fn read_byte_data(file: io::file, command: u8) (u8 | rt::errno) = {
	const data = data {...};
	access(file, READ, command, BYTE_DATA, &data)?;
	return data.byte;
};

export fn read_word_data(file: io::file, command: u8) (u16 | rt::errno) = {
	const data = data {...};
	access(file, READ, command, WORD_DATA, &data)?;
	return data.word;
};

export fn write_byte_data(file: io::file, command: u8, value: u8) (void | rt::errno) = {
	const data = data {
		byte = value,
	};
	access(file, WRITE, command, BYTE_DATA, &data)?;
};

export fn write_word_data(file: io::file, command: u8, value: u16) (void | rt::errno) = {
	const data = data {
		word = value,
	};
	access(file, WRITE, command, WORD_DATA, &data)?;
};
