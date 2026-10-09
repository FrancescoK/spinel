s = +"abc"
h = {k: s}; r = h.to_a[0][1]
r << "!"
p s
p r
