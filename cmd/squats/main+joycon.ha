use bufio;
use errors;
use fmt;
use sensors::joycon;
use time;
use unix::signal;
use unix::tty;
use os;

let exit: bool	= false;

fn sigint(sig: signal::sig, info: *signal::siginfo, ucontext: *opaque) void = {
	exit = true;
};

type status = enum u8 {
	UP,
	DOWN,
	IDLE,
};

def THRESHOLD: f64 = 20.0;

export fn main() void = {
	const joycon = joycon::new(void)!;
	defer joycon::destroy(joycon);

	signal::handle(signal::sig::INT, &sigint, signal::flag::RESTART);

	const screen = tty::isatty(os::stdout_file);

	let count = 0u64;
	let last = status::UP;
	let lastts = time::now(time::clock::MONOTONIC);

	for (let i = 0; !exit; i += 1) {
		const sample = joycon::next_sample(joycon)!;
		const gyro = sample.gyroscope;

		if (i % 50 == 0) {
			if (screen) {
				fmt::print("\x1b[1;1H\x1b[0J")!;
			};

			fmt::printfln("Gyroscope:\t{}\t{}\t{}\tdps\n",
				gyro.0, gyro.1, gyro.2)!;
			const s = if (gyro.1 > THRESHOLD) status::UP
				else if (gyro.1 < -THRESHOLD) status::DOWN
				else status::IDLE;
			const want = if (last == status::UP) status::DOWN
				else status::UP;
			const ts = time::now(time::clock::MONOTONIC);
			if (s == want && time::diff(lastts, ts) > time::SECOND) {
				last = s;
				lastts = ts;
				count += 1;
			};

			fmt::print(switch (s) {
			case status::UP => yield 'U';
			case status::DOWN => yield 'D';
			case status::IDLE => yield 'X';
			}, count / 2)!;

			if (screen) {
				bufio::flush(os::stdout)!;
			} else {
				fmt::println()!;
			};

		};
	};
};
