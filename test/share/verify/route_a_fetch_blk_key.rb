s = +"abc"
h = {}; r = nil; h.fetch(s) { |k| r = k }
r << "!"
p s
p r
