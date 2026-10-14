# A splat of a typed local that holds no Array spreads as one argument
# into a builtin whose argument count is known only at run time (an
# Integer, a Symbol or a String spreads as itself, nil as nothing): the
# length dispatch read the local as an Array and its C did not compile.
a = [[1, 2], [3, 4]]
k = ARGV.size == 0 ? 3 : 0
p a.assoc(*k)
p({3 => 9}.fetch(*k))
s = ARGV.size == 0 ? :a : :b
p({a: 1}.fetch(*s))
str = ARGV.size == 0 ? "x" : "y"
p({"x" => 5}.fetch(*str))
n = nil
p [1, 2].first(*n)
