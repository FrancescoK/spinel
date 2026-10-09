s = +"abc"
u = s
u << "x"
t = s.capitalize
t << "!"
p s, t, t.equal?(s)
