s = +"abc"
u = s
u << "x"
t = s.reverse
t << "!"
p s, t, t.equal?(s)
