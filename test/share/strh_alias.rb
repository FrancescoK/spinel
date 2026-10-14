# spinel: share
# spinel: gc-minor
# Two names of one Array of shared Strings are the one Array.
a = [+"a"]
b = a
b << +"b"
b[0] << "!"
a[1] << "?"
p a, b, a.size
a = [+"c"]
a << +"d"
p a, b
c = [+"x", +"y"]
d = c
d[0] = +"new"
d.push(+"z")
p c, d.size
