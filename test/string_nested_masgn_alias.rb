# A target of a nested multiple assignment that an Array literal element
# names is that element's String, as in CRuby: `(t, u), v = [s, 1], 2`
# makes t another name for s, as `t, u = s, 1` does. The nested target
# was bound to a copy, and an append to it never reached s.

s = +"s"
(t, u), v = [s, 1], 2
t << "!"
p s, u, v
a = +"a"
((x, y), z), w = [[a, 1], 2], 3
x.upcase!
p a
b = +"b"
(m, n), o = [b, 1], 2
b << "?"
p m
q = +"q"
(r1, r2), r3 = [q, +"k"], 2
r2 << "z"
p q, r2
