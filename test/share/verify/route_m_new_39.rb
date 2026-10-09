s = +"abc"
u = s
u << "x"
t = s.partition("z")[0]
t << "!"
p s, t, t.equal?(s)
