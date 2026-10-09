s = +"abc"
u = s
u << "x"
t = s.chop
t << "!"
p s, t, t.equal?(s)
