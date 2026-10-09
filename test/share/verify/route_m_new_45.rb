s = +"abc"
u = s
u << "x"
t = s.to_sym.to_s
t << "!"
p s, t, t.equal?(s)
