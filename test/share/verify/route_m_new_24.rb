s = +"abc"
u = s
u << "x"
t = s.dup
t << "!"
p s, t, t.equal?(s)
