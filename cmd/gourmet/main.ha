use bufio;
use fmt;
use os;
use strings;
use log;
use path;

export fn main() void = {
	let buf = path::init()!;
	match (gourmet_path(&buf)) {
	case void => void;
	case let err: path::error =>
		fmt::fatal("Invalid Path:", path::strerror(err));
	};
	log::println(path::string(&buf));
};

fn gourmet_path(buf: *path::buffer) (void | path::error) = {
	match (os::getenv("XDG_DATA_HOME")) {
	case let this: str =>
		path::push(buf, this)?;
	case void =>
		match (os::getenv("HOME")) {
		case let this: str =>
			path::push(buf, this)?;
			path::push(buf, ".local/share")!;
		case void =>
			fmt::fatal("No XDG_DATA_HOME nor HOME, exiting.");
		};
	};
	path::push(buf, "gourmet")!;
};



