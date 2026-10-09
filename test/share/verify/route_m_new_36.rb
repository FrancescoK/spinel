s = +"abc"
u = s
u << "x"
t = s.delete_suffix("z")
t << "!"
p s, t, t.equal?(s)
