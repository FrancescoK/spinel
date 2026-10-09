s = +"abc"
h = {k: s}; r = h.map { |pair| pair[1] }.first
r << "!"
p s
p r
