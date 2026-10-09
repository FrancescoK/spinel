s = +"abc"
u = s
u << "x"
t = s.rjust(1)
t << "!"
p s, t, t.equal?(s)
