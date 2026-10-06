# Array#concat and String#concat take every argument as it was before any
# is appended, as CRuby does: an argument aliasing the receiver is not the
# grown receiver. a.concat(a, a) appended 8 elements where CRuby has 6.
a = [1, 2]
a.concat(a, a)
p a
b = [1]
c = b.concat(b, [3], b)
p c
s = ["x"]
s.concat(s, s)
p s
s = +"ab"
s.concat(s, s)
p s
t = +"x"
u = t.concat(t, "y", t)
p u
x = [1]
y = [2]
x.concat(y, x, y)
p x
pa = [1, "a"]
pa.concat(pa, pa)
p pa
