use errors;
use fmt;
use fs;
use i2c;
use i2c::smbus;
use io;
use os;
use rt;

export fn new(bus: int) (ADXL345 | fs::error | errors::error) = {
	const path = fmt::asprintf("/dev/i2c-{}", bus);
	defer free(path);
	const file = os::open(path, fs::flags::RDONLY)?;
	match (rt::ioctl(file, i2c::I2C_SLAVE, 0x53)) {
	case let e: rt::errno =>
		return errors::errno(e);
	case =>
		yield;
	};
	return alloc(ADXL345_impl {
		file = file,
	});
};

export fn init(sensor: ADXL345) (void | errors::error) = {
	i2c::smbus::write_byte_data(sensor.file, REG_POWER_CTL, POWER_CTL_MEASURE)?;
	i2c::smbus::write_byte_data(sensor.file, REG_DATA_FORMAT, DATA_FORMAT_FULL_RES)?;
};

fn read_data(sensor: ADXL345, reg: u8) (f64 | errors::error) = {
	const raw = i2c::smbus::read_word_data(sensor.file, reg)?;
	const raw = raw: i16;
	return raw: f64 * SCALE_FACTOR_FULL_RES;
};

export fn read(sensor: ADXL345) ((f64, f64, f64) | errors::error) = {
	return (
		read_data(sensor, REG_DATAX0)?,
		read_data(sensor, REG_DATAY0)?,
		read_data(sensor, REG_DATAZ0)?,
	);
};

export fn destroy(sensor: ADXL345) void = {
	io::close(sensor.file)!;
	free(sensor);
};
