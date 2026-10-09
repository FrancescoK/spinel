s = +"abc"
u = s
u << "x"
t = s.lines[0]
t << "!"
p s, t, t.equal?(s)
