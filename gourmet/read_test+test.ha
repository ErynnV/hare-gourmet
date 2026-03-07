use memio;
use io;
use strings;

@test fn test_read() void = {
	const content = `
[global]
title=test
prep-time=1
cook-time=2
[ingredient]
name=foo
count=10
[ingredient]
name=bar
count=8
[step]
desc=lorem ipsum
[step]
desc=sit do lorem
`;
	const in = memio::fixed(strings::toutf8(content));
	const subj = read(&in);
	assert(subj is recipe);
	const subj = subj as recipe;
	defer finish(&subj);
	assert(subj.title == "test");
	assert(subj.prep_time == 1);
	assert(subj.cook_time == 2);
	assert(len(subj.ingredients) == 2);
	assert(subj.ingredients[0].name == "foo");
	assert(subj.ingredients[0].count == 10);
	assert(subj.ingredients[1].name == "bar");
	assert(subj.ingredients[1].count == 8);
	assert(len(subj.steps) == 2);
	assert(subj.steps[0].desc == "lorem ipsum");
	assert(subj.steps[1].desc == "sit do lorem");
};
