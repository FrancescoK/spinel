# A boxed String key reads its current bytes in builtin lookups, including
# misses after a mutation and a Hash whose keys have different kinds.
key = +"key"
alias_key = key
alias_key << "!"
boxed_key = [key, 7][ARGV.size]
ints = [{ "key!" => 12 }, 0][ARGV.size]
values = [{ "key!" => [1, 2] }, 0][ARGV.size]
p ints[boxed_key], values[boxed_key]
alias_key.replace("missing")
p ints[boxed_key], values[boxed_key]
alias_key.replace("key!")
text = ["a key! z", 0][ARGV.size]
p text[boxed_key]

mixed = { 1 => "number", "key!" => "string" }
mixed_box = [mixed, 0][ARGV.size]
p mixed_box[boxed_key], mixed_box[1], ints[1]
