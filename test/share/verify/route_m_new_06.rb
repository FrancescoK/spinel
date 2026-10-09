s = +"abc"
u = s
u << "x"
t = s.sub("zz", "")
t << "!"
p s, t, t.equal?(s)
