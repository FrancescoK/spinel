s = +"abc"
u = s
u << "x"
t = s.chomp
t << "!"
p s, t, t.equal?(s)
