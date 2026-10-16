# spinel: share
# spinel: gc-minor
# An Array of shared Strings gives way to a value whose type inference does
# not know, a bare Array.new: it is boxed, which is no String's handle, so
# the Array is the general one and holds it as it is, whether it is pushed
# or stored at an index.
s = +"ab"
a = [s, "x"]
s << "!"
a.push(Array.new)
p a, a.size

b = [s, "x"]
s << "?"
b[0] = Array.new
p b, b.size

s << "."
# one that holds only Strings keeps the handles
d = [s, "y"]
s << "~"
d.push(+"z")
d[1] = s
p d, d[1].equal?(s)
