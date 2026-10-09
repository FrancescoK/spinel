s = +"abc"
u = s
u << "x"
t = s.slice(/.+/)
t << "!"
p s, t, t.equal?(s)
