s = +"abc"
h = Hash.new(s); r = h[:missing]
r << "!"
p s
p r
