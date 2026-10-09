s = +"abc"
h = {k: s}; r = h.min_by { |k, v| v }[1]
r << "!"
p s
p r
