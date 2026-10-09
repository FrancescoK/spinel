h = {}
s = +"abc"
h.store(:k, s)
(h[:k]) << "?"
p s
p(h[:k])
