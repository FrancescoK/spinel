s = +"abc"
u = s
u << "x"
t = s.unpack1("a*")
t << "!"
p s, t, t.equal?(s)
