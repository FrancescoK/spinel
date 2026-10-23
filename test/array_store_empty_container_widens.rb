# An empty container pushed into or stored in an Array of scalars, a bare
# Array.new as well as a literal, makes it the general Array: the push of a
# bare Array.new raised TypeError, and a store of one at an index was refused.
c = ["q"]
c.push(Array.new)
p c
d = ["q"]
d[0] = Array.new
p d
e = [1]
e[1] = []
p e
f = [1.5]
f[0] = Hash.new
f << {}
p f
