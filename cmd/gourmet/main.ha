use bufio;
use fmt;
use os;
use strings;
use log;
use path;
use fs;
use io;
use gourmet;
use getopt;

export fn main() void = {
	let buf = path::init()!;
	match (gourmet_path(&buf)) {
	case void => void;
	case let err: path::error =>
		fmt::fatal("Invalid Path:", path::strerror(err));
	};

	let recs = match (load_recipes(buf)) {
	case let this: []gourmet::recipe =>
		yield this;
	case let err: io::error =>
		fmt::fatal("Reading error:", io::strerror(err));
	case let err: gourmet::error =>
		fmt::fatal("Format error:", gourmet::strerror(err));
	case let err: fs::error =>
		fmt::fatal("Fs error:", fs::strerror(err));
	case nomem =>
		abort();
	};
	defer {
		for (let rec &.. recs) {
			gourmet::finish(rec);
		};
		free(recs);
	};

	const help: []getopt::help = [
		"recipe book",
		("list", []): getopt::subcmd_help,
	];

	const cmd = getopt::parse(os::args, help...);
	defer getopt::finish(&cmd);


	let exec = match (cmd.subcmd){
	case void =>
		getopt::printhelp(os::stderr, os::args[0], help)!;
		os::exit(1);
	case let subcmd: (str, *getopt::command) =>
		yield switch (subcmd.0) {
		case "list" =>
			yield &exec_list;
		case =>
			getopt::printhelp(os::stderr, os::args[0], help)!;
			os::exit(1);
		};
	};
	exec(recs, cmd);
};

fn exec_list(recs: []gourmet::recipe, cmd: getopt::command) void = {
	for (let rec &.. recs) {
		fmt::println(rec.title)!;
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

fn load_recipes(
	buf: path::buffer,
) ([]gourmet::recipe | io::error | gourmet::error | fs::error | nomem)  = {
	let iter = os::iter(path::string(&buf))?;
	defer fs::finish(iter);
	let recs: []gourmet::recipe = [];
	for (let dir => fs::next(iter)!) {
		path::push(&buf, dir.name)!;
		defer path::pop(&buf);
		let file = os::open(path::string(&buf))?;
		defer io::close(file)!;
		append(recs, gourmet::read(file)?)?;
	};
	return recs;
};
