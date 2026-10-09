s = +"abc"
u = s
u << "x"
t = s.encode("UTF-8", invalid: :replace)
t << "!"
p s, t, t.equal?(s)
