s = +"abc"
u = s
u << "x"
t = s.downcase
t << "!"
p s, t, t.equal?(s)
