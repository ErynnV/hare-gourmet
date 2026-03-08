use io;
use format::ini;
use strings;
use strconv;

use log;

export fn read(
	in: io::handle,
) (recipe | error | nomem) = {
	const scan = ini::scan(in);
	defer ini::finish(&scan);

	const rec = recipe {
		...
	};

	let tmp_ing = ingredient {
		...
	};

	for (true) {
		let ent = match (ini::next(&scan)) {
		case let this: ini::entry =>
			yield this;
		case io::EOF =>
			break;
		case let err: ini::error =>
			return err: error;
		case nomem =>
			return nomem;
		};

		switch (ent.0) {
		case "global" =>
			switch (ent.1) {
			case "title" =>
				rec.title = strings::dup(ent.2)?;
			case "prep-time" =>
				rec.prep_time = stou(ent.2)?;
			case "cook-time" =>
				rec.cook_time = stou(ent.2)?;
			case =>
				return invalid;
			};
		case "ingredient" =>
			switch (ent.1) {
			case "name" =>
				tmp_ing.name = strings::dup(ent.2)?;
			case "count" =>
				tmp_ing.count = stou(ent.2)?;
			case =>
				return invalid;
			};
			if (tmp_ing.name != "" && tmp_ing.count != 0) {
				append(rec.ingredients, tmp_ing)?;
				tmp_ing = ingredient { ... };
			};
		case "step" =>
			switch (ent.1) {
			case "desc" =>
				append(rec.steps, step {
					desc = strings::dup(ent.2)?,
				})?;
			case =>
				return	invalid;
			};
		case =>
			return invalid;
		};

	};

	return rec;
};

export fn finish(rec: *recipe) void = {
	free(rec.title);
	for (let ing &.. rec.ingredients) {
		free(ing.name);
	};
	free(rec.ingredients);
	for (let step &.. rec.steps) {
		free(step.desc);
	};
	free(rec.steps);
};

fn stou(in: str) (uint | invalid) = {
	match (strconv::stou(in)) {
	case let this: uint =>
		return this;
	case =>
		return invalid;
	};
};
