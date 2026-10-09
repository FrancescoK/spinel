# spinel: share
s = +"abc"
u = s
u << "x"
t = String.new(s)
t << "!"
p s, t, t.equal?(s)
