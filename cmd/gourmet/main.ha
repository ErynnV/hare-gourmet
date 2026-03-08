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
		("show", [
			"id",
		]): getopt::subcmd_help,

	];

	const cmd = getopt::parse(os::args, help...);
	defer getopt::finish(&cmd);

	let (exec, subcmd) = match (cmd.subcmd) {
	case void =>
		getopt::printhelp(os::stderr, os::args[0], help)!;
		os::exit(1);
	case let subcmd: (str, *getopt::command) =>
		yield switch (subcmd.0) {
		case "list" =>
			yield (&exec_list, subcmd.1);
		case "show" =>
			if (len(subcmd.1.args) == 0) {
				getopt::printhelp(os::stderr, os::args[0], help)!;
				os::exit(1);
			};
			yield (&exec_show, subcmd.1);
		case =>
			getopt::printhelp(os::stderr, os::args[0], help)!;
			os::exit(1);
		};
	};
	exec(recs, subcmd);
};

fn exec_list(recs: []gourmet::recipe, cmd: *getopt::command) void = {
	for (let rec &.. recs) {
		fmt::printfln("{}: {}", rec.id, rec.title,)!;
	};
};

fn exec_show(recs: []gourmet::recipe, cmd: *getopt::command) void = {
	const id = cmd.args[0];
	let rec = for (let rec &.. recs) {
		if (rec.id == id) {
			break rec;
		};
	} else {
		fmt::fatal("No matching id.");
	};
	fprint_show_recipe(os::stdout, rec)!;
};

#[template::gen(rec: *gourmet::recipe)]
def show_recipe = `
{{- rec.title }}
Preparation time: {{ rec.prep_time }}min and Cooking time: {{ rec.cook_time }}min

Ingredients:
{{- for (let ing &.. rec.ingredients) }}
- {{ ing.name }}: {{ ing.count }} {{ ing.unit }}
{{- end }}
{{- for (let step &.. rec.steps) }}

{{ step.desc}}
{{- end }}
`;

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
		append(recs, gourmet::read(file, dir.name)?)?;
	};
	return recs;
};
