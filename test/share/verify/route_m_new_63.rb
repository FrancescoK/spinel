s = +"abc"
u = s
u << "x"
t = s.match(/.+/)[0]
t << "!"
p s, t, t.equal?(s)
