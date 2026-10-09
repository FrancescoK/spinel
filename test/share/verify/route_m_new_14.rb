s = +"abc"
u = s
u << "x"
t = s.center(1)
t << "!"
p s, t, t.equal?(s)
