s = +"abc"
r = nil; h = {k: s}; h.each { |pair| r = pair[1] }
r << "!"
p s
p r
