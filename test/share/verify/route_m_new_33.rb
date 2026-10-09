s = +"abc"
u = s
u << "x"
t = s.succ
t << "!"
p s, t, t.equal?(s)
