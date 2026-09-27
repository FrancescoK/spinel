# `[]` on a Struct or Data class read out of a container constructs it, as
# `new` does; `[]` on any other value in the same place keeps its meaning.
S = Struct.new(:a, :b)
T = Struct.new(:x, :y, :z)
D = Data.define(:x, :y)

def try
  yield
rescue ArgumentError => e
  p [e.class, e.message]
end

s = [S, 0][0]
t = [T, 0][0]
d = [D, 0][0]

p s[1, 2]
p s[1]
p s[]
p t[1, "two", [3]]
p d[3, 4]
try { p s[1, 2, 3] }

# the members read back through their own readers
v = s[3, 4]
p [v.class, v.to_a, v.a + v.b]
w = d["x", nil]
p [w.x, w.y]

# an anonymous Struct class, as Struct.new answers it
s0 = Struct.new(:a, :b)
u = [s0, 0][0]
p u[3, 4].to_a

# one call site over classes and other values
[[1, 2, 3], "hello", S, "world", D].each do |r|
  p r[1, 2]
end
