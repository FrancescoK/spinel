s = +"abc"
u = s
u << "x"
t = s.freeze.dup
t << "!"
p s, t, t.equal?(s)
