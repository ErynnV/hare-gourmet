export type recipe = struct {
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
