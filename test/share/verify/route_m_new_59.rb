s = +"abc"
u = s
u << "x"
t = s.to_str.dup
t << "!"
p s, t, t.equal?(s)
