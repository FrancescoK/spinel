s = +"abc"
u = s
u << "x"
t = s.then { |x| x.dup }
t << "!"
p s, t, t.equal?(s)
