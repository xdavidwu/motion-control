use io;
use rt;

export fn read_byte_data(file: io::file, command: u8) (u8 | rt::errno) = {
	const res = c_i2c_smbus_read_byte_data(file: int, command);
	return if (res < 0) res: rt::errno else res: u8;
};

export fn read_word_data(file: io::file, command: u8) (u16 | rt::errno) = {
	const res = c_i2c_smbus_read_word_data(file: int, command);
	return if (res < 0) res: rt::errno else res: u16;
};

export fn write_byte_data(file: io::file, command: u8, value: u8) (void | rt::errno) = {
	const res = c_i2c_smbus_write_byte_data(file: int, command, value);
	return if (res < 0) res: rt::errno else void;
};

export fn write_word_data(file: io::file, command: u8, value: u16) (void | rt::errno) = {
	const res = c_i2c_smbus_write_word_data(file: int, command, value);
	return if (res < 0) res: rt::errno else void;
};

@symbol("i2c_smbus_read_byte_data") fn c_i2c_smbus_read_byte_data(file: int, command: u8) i32;
@symbol("i2c_smbus_read_word_data") fn c_i2c_smbus_read_word_data(file: int, command: u8) i32;
@symbol("i2c_smbus_write_byte_data") fn c_i2c_smbus_write_byte_data(file: int, command: u8, value: u8) i32;
@symbol("i2c_smbus_write_word_data") fn c_i2c_smbus_write_word_data(file: int, command: u8, value: u16) i32;
