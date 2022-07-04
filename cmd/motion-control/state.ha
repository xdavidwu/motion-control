use fmt;
use unix::signal;

type state = enum u8 {
	NORMAL,
	BLOCK,
	RESET,
	EXIT,
};

let global_state: state	= state::NORMAL;

fn sigint(sig: int, info: *signal::siginfo, ucontext: *void) void = {
	global_state = state::EXIT;
};

fn sigusr1(sig: int, info: *signal::siginfo, ucontext: *void) void = {
	switch (global_state) {
	case state::NORMAL =>
		fmt::println("Block")!;
		global_state = state::BLOCK;
	case state::BLOCK =>
		fmt::println("Reset")!;
		global_state = state::RESET;
	case state::RESET =>
		fmt::println("Reset is already pending")!;
	case state::EXIT =>
		fmt::println("Exit pending")!;
	};
};
