s = +"abc"
u = s
u << "x"
t = s.to_s.dup
t << "!"
p s, t, t.equal?(s)
