s = +"abc"
u = s
u << "x"
t = s.encode("UTF-8")
t << "!"
p s, t, t.equal?(s)
