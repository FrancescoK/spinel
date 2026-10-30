s = +"abc"
u = s
u << "x"
t = +s.to_sym.to_s   # (+: a Symbol's to_s is frozen in Spinel)
t << "!"
p s, t, t.equal?(s)
