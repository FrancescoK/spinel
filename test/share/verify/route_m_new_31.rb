s = +"abc"
u = s
u << "x"
t = [s].join
t << "!"
p s, t, t.equal?(s)
