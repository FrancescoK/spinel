# A Struct built through a class value takes the arguments of that `new`
# into its members, as a direct `S.new` does: a String member handed an
# Integer through `[A, B][i].new(7)` or `Object.const_get(name).new(7)` is
# one that can hold both. It was left a String, and the switch's arm read
# the Integer as a String pointer (#9093)
A = Struct.new(:a)
B = Struct.new(:b)
V = Struct.new(:v, :w)
p B.new("s"), V.new(0.5, 1)
k = [A, B][ENV["NO_SUCH_VAR_9093"] ? 0 : 1]
p k.new(7)
d = Object.const_get(ENV["NO_SUCH_VAR_9093"] || "B")
p d.new(8), d.new([1])
v = Object.const_get(ENV["NO_SUCH_VAR_9093"] || "V")
p v.new(2.5), v.new("x", nil)
[B.new("t"), A.new(1)].each { |o| p o.class.new(9) }
p Struct.new(:x, :y).new(1, 2).to_a
