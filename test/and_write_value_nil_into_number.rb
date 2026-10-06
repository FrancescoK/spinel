# The value of `x &&= v` on a nil Integer or Float local is nil, and so is
# `x ||= v` with a nil v: a number local it is copied into holds nil too,
# also when it is boxed beside another value or x is captured.
h = nil
h = 2.0 if ARGV.size > 2
k = (h &&= 3.0)
p k, [1, "a"][ARGV.size]
i = nil
i = 2 if ARGV.size > 2
m = -> { i }
j = (i &&= 3)
p j, m.call, [j].first.nil?
f = 5
f = nil if ARGV.size < 2
g = (f &&= 6)
p g, [1, "a"][ARGV.size]
n = 1.5
n = 2.5 if ARGV.size > 2
o = (n &&= 4.5)
p o, [1, "a"][ARGV.size]
