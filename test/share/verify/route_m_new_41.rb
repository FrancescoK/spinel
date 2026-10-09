s = +"abc"
u = s
u << "x"
t = s.chars.join
t << "!"
p s, t, t.equal?(s)
