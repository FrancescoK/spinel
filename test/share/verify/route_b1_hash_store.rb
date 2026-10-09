h = {}
s = +"abc"
h.store(:k, s)
s << "!"
p(h[:k])
p s
