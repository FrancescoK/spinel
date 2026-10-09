s = +"abc"
u = s
u << "x"
t = s.dump.undump
t << "!"
p s, t, t.equal?(s)
