s = +"abc"
u = s
u << "x"
t = s.clone
t << "!"
p s, t, t.equal?(s)
