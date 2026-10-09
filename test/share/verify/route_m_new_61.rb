s = +"abc"
u = s
u << "x"
t = s.each_line.first
t << "!"
p s, t, t.equal?(s)
