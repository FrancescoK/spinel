# A bare Array.new / Hash.new is the same empty container as [] / {}
# (#3613): read back out of a literal beside other values, it is the
# container, not the other elements' type.
x = Array.new
y = [x, 1][0]
p y
y << 5
p x
a = [x, 1]
z = a[0]
p z.equal?(x)
w = [1, x][1]
p w
i = 0
v = [x, "s"][i]
p v
h = Hash.new
g = [h, 1][0]
p g
g["k"] = 2
g[:s] = 3
p h
d = Hash.new
d.default_proc = ->(hh, k) { k * 2 }
p d[2], [d, 1][0][3]
p [Array.new, 2.5][0], [Hash.new, :s][0]
u = [Array.new, 1][0]
u << 7
p u
e = Array.new
p e, e.size
f = Hash.new
p f, f.empty?
