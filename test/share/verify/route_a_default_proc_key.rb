s = +"abc"
r = nil; h = Hash.new { |hh, k| r = k }; h[s]
r << "!"
p s
p r
