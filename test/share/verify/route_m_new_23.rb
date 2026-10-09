s = +"abc"
u = s
u << "x"
t = s.b
t << "!"
p s, t, t.equal?(s)
