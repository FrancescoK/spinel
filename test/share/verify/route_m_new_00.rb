s = +"abc"
u = s
u << "x"
t = s.strip
t << "!"
p s, t, t.equal?(s)
