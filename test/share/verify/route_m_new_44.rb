s = +"abc"
u = s
u << "x"
t = s.inspect[1..-2]
t << "!"
p s, t, t.equal?(s)
