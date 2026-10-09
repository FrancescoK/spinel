s = +"abc"
h = {k: s}; r = h.find { |k, v| true }[1]
r << "!"
p s
p r
