s = +"abc"
u = s
u << "x"
t = s.ascii_only? ? s.dup : s
t << "!"
p s, t, t.equal?(s)
