s = +"abc"
u = s
u << "x"
t = s.crypt("ab").replace(s)
t << "!"
p s, t, t.equal?(s)
