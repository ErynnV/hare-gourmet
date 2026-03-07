use bufio;
use fmt;
use os;
use strings;
use log;
use path;
use fs;
use io;

export fn main() void = {
	let buf = path::init()!;
	match (gourmet_path(&buf)) {
	case void => void;
	case let err: path::error =>
		fmt::fatal("Invalid Path:", path::strerror(err));
	};
	let iter = match (os::iter(path::string(&buf))) {
	case let this: *fs::iterator =>
		yield this;
	case let err: fs::error =>
		fmt::fatal("Reading gourmet data directory:", fs::strerror(err));
	};
	defer fs::finish(iter);
	for (let dir => fs::next(iter)!) {
		path::push(&buf, dir.name)!;
		defer path::pop(&buf);
		let file = os::open(path::string(&buf))!;
		defer io::close(file)!;
	};
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



