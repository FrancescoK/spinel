s = +"abc"
u = s
u << "x"
t = s.upcase
t << "!"
p s, t, t.equal?(s)
