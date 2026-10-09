s = +"abc"
h = Hash.new { |hh, k| hh[k] = s }; h[:x]; r = h[:x]
r << "!"
p s
p r
