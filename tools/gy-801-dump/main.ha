use fmt;
use fs;
use os;
use rt;
use sensors::ADXL345;
use strconv;

export fn main() void = {
	if (len(os::args) != 2) {
		fmt::fatalf("Usage: {} bus", os::args[0]);
	};
	const bus = match (strconv::stoi(os::args[1])) {
	case let bus: int =>
		yield bus;
	case =>
		fmt::fatal("bus should be a integer");
	};

	const ADXL345 = match (ADXL345::new(bus)) {
	case let ADXL345: ADXL345::ADXL345 =>
		yield ADXL345;
	case let err: fs::error =>
		fmt::fatalf("Cannot open i2c device: {}", fs::strerror(err));
	case let err: rt::errno =>
		fmt::fatalf("Cannot ioctl i2c device: {}", rt::strerror(err));
	};
	defer ADXL345::destroy(ADXL345);

	ADXL345::init(ADXL345)!;

	const acc_readings = ADXL345::read(ADXL345)!;

	fmt::printfln("Accelerometer: {} {} {} g", acc_readings.0, acc_readings.1, acc_readings.2)!;
};
