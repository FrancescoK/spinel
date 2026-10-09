s = +"abc"
u = s
u << "x"
t = s.insert(0, "").dup
t << "!"
p s, t, t.equal?(s)
