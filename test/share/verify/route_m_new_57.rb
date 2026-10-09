s = +"abc"
u = s
u << "x"
t = -s + ""
t << "!"
p s, t, t.equal?(s)
