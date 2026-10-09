s = +"abc"
u = s
u << "x"
t = s.scan(/.+/)[0]
t << "!"
p s, t, t.equal?(s)
