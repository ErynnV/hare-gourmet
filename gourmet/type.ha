use format::ini;

export type recipe = struct {
	id: str,
	title: str,
	prep_time: uint,
	cook_time: uint,
	ingredients: []ingredient,
	steps: []step,
};

export type ingredient = struct {
	name: str,
	count: uint,
};

export type step = struct {
	desc: str,
};

export type invalid = !void;

export type error = !(ini::error | invalid);

export fn strerror(err: error) str = {
	match (err) {
	case let err: ini::error =>
		return ini::strerror(err);
	case invalid =>
		return "Invalid";
	};
};
