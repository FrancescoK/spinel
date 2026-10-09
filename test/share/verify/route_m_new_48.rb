s = +"abc"
u = s
u << "x"
t = s.tr_s("z", "y")
t << "!"
p s, t, t.equal?(s)
