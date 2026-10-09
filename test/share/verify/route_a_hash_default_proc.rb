s = +"abc"
h = Hash.new { |hh, k| s }; r = h[:missing]
r << "!"
p s
p r
