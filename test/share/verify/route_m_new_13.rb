s = +"abc"
u = s
u << "x"
t = s.swapcase
t << "!"
p s, t, t.equal?(s)
