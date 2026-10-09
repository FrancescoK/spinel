s = +"abc"
u = s
u << "x"
t = s.delete_prefix("z")
t << "!"
p s, t, t.equal?(s)
