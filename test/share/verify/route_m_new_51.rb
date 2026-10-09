s = +"abc"
u = s
u << "x"
t = s.force_encoding("UTF-8").dup
t << "!"
p s, t, t.equal?(s)
