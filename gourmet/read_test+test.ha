use memio;
use io;
use strings;

@test fn test_read() void = {
	const content = `
[global]
title=une recette test
prep-time=1
cook-time=2
[ingredient]
name=foo
count=10
unit=g
[ingredient]
name=bar
count=8
unit=piece
[step]
desc=lorem ipsum
[step]
desc=sit do lorem
`;
	const in = memio::fixed(strings::toutf8(content));

	const subj = read(&in, "test");
	assert(subj is recipe);
	const subj = subj as recipe;
	defer finish(&subj);
	assert(subj.id == "test");
	assert(subj.title == "une recette test");
	assert(subj.prep_time == 1);
	assert(subj.cook_time == 2);
	assert(len(subj.ingredients) == 2);
	assert(subj.ingredients[0].name == "foo");
	assert(subj.ingredients[0].count == 10);
	assert(subj.ingredients[0].unit == "g");
	assert(subj.ingredients[1].name == "bar");
	assert(subj.ingredients[1].count == 8);
	assert(subj.ingredients[1].unit == "piece");
	assert(len(subj.steps) == 2);
	assert(subj.steps[0].desc == "lorem ipsum");
	assert(subj.steps[1].desc == "sit do lorem");
};
