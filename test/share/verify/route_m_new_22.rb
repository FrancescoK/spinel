s = +"abc"
u = s
u << "x"
t = s.scrub
t << "!"
p s, t, t.equal?(s)
