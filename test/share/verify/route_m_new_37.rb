s = +"abc"
u = s
u << "x"
t = s.each_char.to_a.join
t << "!"
p s, t, t.equal?(s)
