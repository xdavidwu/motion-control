use fmt;
use fs;
use i2c;
use i2c::smbus;
use io;
use os;
use rt;

export fn new(bus: int) (L3G4200D | fs::error | rt::errno) = {
	const path = fmt::asprintf("/dev/i2c-{}", bus);
	defer free(path);
	const file = os::open(path, fs::flags::RDONLY)?;
	rt::ioctl(file, i2c::I2C_SLAVE, 0x69)?;
	return alloc(L3G4200D_impl {
		file = file,
	});
};

export fn init(sensor: L3G4200D) (void | rt::errno) = {
	smbus::write_byte_data(sensor.file, REG_CTRL_REG1,
		CTRL_REG1_PD | CTRL_REG1_Zen | CTRL_REG1_Yen | CTRL_REG1_Xen | CTRL_REG1_DR_100HZ)?;
	smbus::write_byte_data(sensor.file, REG_CTRL_REG2, CTRL_REG2_HPCF_0_05HZ_AT_100HZ)?;
	smbus::write_byte_data(sensor.file, REG_CTRL_REG4, CTRL_REG4_BDU)?;
	smbus::write_byte_data(sensor.file, REG_CTRL_REG5, CTRL_REG5_OUT_HP_ONLY)?;
};

fn read_data(sensor: L3G4200D, reg: u8) (f64 | rt::errno) = {
	const raw = smbus::read_byte_data(sensor.file, reg)?;
	const raw2 = smbus::read_byte_data(sensor.file, reg + 1)?;
	const raw = (raw: u16 + (raw2: u16 << 8)): i16;
	return raw: f64 * FS_250DPS_So;
};

export fn read(sensor: L3G4200D) ((f64, f64, f64) | rt::errno) = {
	return (
		read_data(sensor, REG_OUT_X_L)?,
		read_data(sensor, REG_OUT_Y_L)?,
		read_data(sensor, REG_OUT_Z_L)?,
	);
};

export fn destroy(sensor: L3G4200D) void = {
	io::close(sensor.file)!;
	free(sensor);
};
