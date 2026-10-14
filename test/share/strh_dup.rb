# spinel: share
# spinel: gc-minor
# dup is a new Array of the same Strings.
s = +"s"
a = [s, +"t", +"u"]
d = a.dup
d << +"extra"
d[0] << "!"
d[1] << "?"
p a.size, d.size, a, d, s
p a.to_a.size
