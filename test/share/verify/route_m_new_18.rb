s = +"abc"
u = s
u << "x"
t = s[0, 99]
t << "!"
p s, t, t.equal?(s)
