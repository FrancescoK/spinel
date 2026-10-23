# Hash.new(x) answers x for a key it does not hold: a read of a missing
# key, and the Hash's default, can be x, and a call on it dispatches to
# x's class's method
class A; def foo = "A"; end
class B; def foo = "B"; end
class C; def foo = "C"; end

d = Hash.new(B.new)
[A.new, d[:x]].each { |v| puts v.foo }

e = Hash.new(C.new)
[A.new, e.default].each { |v| puts v.foo }

k = Hash.new(B.new)
k[:a] = A.new
k.values.each { |v| puts v.foo }
[C.new, k[:z]].each { |v| puts v.foo }

# a default block's value and Array.new's fill value, as before
f = Hash.new { |h, key| h[key] = C.new }
[A.new, f[:x]].each { |v| puts v.foo }
g = Array.new(2, B.new)
[A.new, g[0]].each { |v| puts v.foo }
