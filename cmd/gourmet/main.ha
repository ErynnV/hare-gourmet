use bufio;
use fmt;
use os;
use strings;

export fn main() void = {
	const recipe = makerecipe();
	sumarize(recipe);
};

// Create recipe
fn makerecipe() str = {
	fmt::println("Recipe name")!;
	const name = bufio::read_line(os::stdin)! as []u8;
	return strings::fromutf8(name)!;
};

// Sumarize
fn sumarize(recipe: str) void = {
	fmt::printfln(recipe)!;
};
