s = +"abc"
u = s
u << "x"
t = s.rstrip
t << "!"
p s, t, t.equal?(s)
