s = +"abc"
u = s
u << "x"
t = s.delete("z")
t << "!"
p s, t, t.equal?(s)
