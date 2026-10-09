s = +"abc"
h = {k: s}; r = h.each_key { |k| k }[:k]
r << "!"
p s
p r
