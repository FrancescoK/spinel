s = +"abc"
u = s
u << "x"
t = s.squeeze
t << "!"
p s, t, t.equal?(s)
