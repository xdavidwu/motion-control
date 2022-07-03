use bufio;
use fmt;
use io;
use os;
use strings;

export fn main() void = {
	for (true) {
		const line = match (bufio::scanline(os::stdin)!) {
		case let s: []u8 =>
			yield strings::fromutf8(s);
		case io::EOF =>
			return;
		};

		if (!strings::hasprefix(line, "#define")) {
			free(line);
			continue;
		};
		const iend = match (strings::index(strings::sub(line, 8, strings::end), '\t')) {
		case void =>
			free(line);
			continue;
		case let s: size =>
			yield s + 8;
		};
		const val = strings::trim(strings::sub(line, iend, strings::end), '\t');
		const val = match (strings::index(val, "/*")) {
		case void =>
			yield val;
		case let s: size =>
			yield strings::sub(val, 0, s);
		};
		fmt::printfln("export def {}: u16\t= {};", strings::sub(line, 8, iend), val)!;

		free(line);
	};
};
