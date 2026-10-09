s = +"abc"
u = s
u << "x"
t = s.slice(0..)
t << "!"
p s, t, t.equal?(s)
