h = {}
s = +"abc"
h[:k] = s
(h[:k]) << "?"
p s
p(h[:k])
