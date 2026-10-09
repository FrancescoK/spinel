s = +"abc"
h = {k: s}; r = h.sort_by { |k, v| v }.first.last
r << "!"
p s
p r
