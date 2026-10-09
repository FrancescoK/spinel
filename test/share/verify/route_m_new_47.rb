s = +"abc"
u = s
u << "x"
t = s.sum.to_s.replace(s)
t << "!"
p s, t, t.equal?(s)
