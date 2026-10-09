s = +"abc"
u = s
u << "x"
t = s.gsub("zz", "")
t << "!"
p s, t, t.equal?(s)
