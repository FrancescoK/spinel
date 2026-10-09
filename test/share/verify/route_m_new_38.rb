s = +"abc"
u = s
u << "x"
t = s.split(",")[0]
t << "!"
p s, t, t.equal?(s)
