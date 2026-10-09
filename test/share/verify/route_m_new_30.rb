s = +"abc"
u = s
u << "x"
t = format("%s", s)
t << "!"
p s, t, t.equal?(s)
