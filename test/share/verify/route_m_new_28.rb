s = +"abc"
u = s
u << "x"
t = s * 1
t << "!"
p s, t, t.equal?(s)
