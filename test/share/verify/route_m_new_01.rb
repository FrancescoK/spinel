s = +"abc"
u = s
u << "x"
t = s.lstrip
t << "!"
p s, t, t.equal?(s)
