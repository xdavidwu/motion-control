use errors;
use evdev;
use fmt;
use fs;
use io;
use os;
use strings;
use types;

export fn new(dev: (io::file | void)) (joycon | errors::error) = {
	match (dev) {
	case let f: io::file =>
		return alloc(joycon_impl { dev = evdev::new_from_fd(f)?, ... });
	case void =>
		const preferences: []const str = [
			"Nintendo Switch Pro Controller IMU",
			"Nintendo Switch Right Joy-Con IMU (Grip)",
			"Nintendo Switch Left Joy-Con IMU (Grip)",
			"Nintendo Switch Right Joy-Con IMU",
			"Nintendo Switch Left Joy-Con IMU",
		];
		const fs = os::diropen("/dev/input")!;
		const iter = fs::iter(fs, ".")!;
		let candidate = struct {
			fd: io::file = 0,
			dev: evdev::libevdev = 0: uintptr,
			preference: size = len(preferences),
		};
		let has_candidate = false;

		for (true) {
			const ent = match (fs::next(iter)) {
			case let e: fs::dirent =>
				if (!fs::ischdev(e.ftype)) {
					continue;
				};
				yield e.name;
			case void =>
				break;
			};
			const f = match (fs::open_file(fs, ent)) {
			case let f: io::file =>
				yield f;
			case let e: fs::error =>
				fmt::errorfln("Cannot probe {}: {}", ent, fs::strerror(e))!;
				continue;
			};
			const e = evdev::new_from_fd(f)!;
			const name = evdev::get_name(e);

			let eligible = false;
			for (let i = 0z; i < candidate.preference; i += 1) {
				if (strings::compare(name, preferences[i]) == 0) {
					has_candidate = true;
					eligible = true;
					candidate.fd = f;
					candidate.dev = e;
					candidate.preference = i;
					break;
				};
			};

			if (!eligible) {
				evdev::destroy(e);
				io::close(f)!;
			};
		};
		fs::finish(iter);

		if (!has_candidate) {
			return errors::noentry;
		};

		fmt::printfln("Picking {}", preferences[candidate.preference])!;
		return alloc(joycon_impl {
			fd = candidate.fd,
			dev = candidate.dev,
			...
		});
	};
};

export fn destroy(joycon: joycon) void = {
	evdev::destroy(joycon.dev);
	if (joycon.fd != 0) {
		io::close(joycon.fd)!;
	};
	free(joycon);
};

// +-8g, 16-bit signed
def ACCEL_SCALE: f64 = 8.0 / types::I16_MAX: f64;

// +-2000dps, 16-bit signed, hid-nintendo * 1000 for calibration precision
def GYRO_SCALE: f64 = 2.0 / types::I16_MAX: f64;

export fn next_sample(joycon: joycon) (sample | errors::error) = {
	let ev = evdev::input_event {...};
	for (true) {
		switch (evdev::next_event(joycon.dev, evdev::read_flag::NORMAL, &ev)?) {
		case evdev::read_status::SUCCESS =>
			yield;
		case evdev::read_status::SYNC =>
			continue;
		};
		switch (ev._type) {
		case evdev::EV_SYN =>
			if (joycon.read == READ_FULL) {
				return joycon.state;
			} else {
				continue;
			};
		case evdev::EV_ABS =>
			switch (ev.code) {
			case evdev::ABS_X =>
				joycon.read |= READ_X;
				joycon.state.accelerometer.0 =
					ev.value: f64 * ACCEL_SCALE;
			case evdev::ABS_Y =>
				joycon.read |= READ_Y;
				joycon.state.accelerometer.1 =
					ev.value: f64 * ACCEL_SCALE;
			case evdev::ABS_Z =>
				joycon.read |= READ_Z;
				joycon.state.accelerometer.2 =
					ev.value: f64 * ACCEL_SCALE;
			case evdev::ABS_RX =>
				joycon.read |= READ_RX;
				joycon.state.gyroscope.0 =
					ev.value: f64 * GYRO_SCALE;
			case evdev::ABS_RY =>
				joycon.read |= READ_RY;
				joycon.state.gyroscope.1 =
					ev.value: f64 * GYRO_SCALE;
			case evdev::ABS_RZ =>
				joycon.read |= READ_RZ;
				joycon.state.gyroscope.2 =
					ev.value: f64 * GYRO_SCALE;
			};
		case evdev::EV_MSC =>
			assert(ev.code == evdev::MSC_TIMESTAMP);
			joycon.state.timestamp = ev.value: u32;
		};
	};
	abort("Unreachable");
};
