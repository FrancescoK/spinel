s = +"abc"
h = {}; h.default = s; r = h[:missing]
r << "!"
p s
p r
