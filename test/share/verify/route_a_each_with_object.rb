s = +"abc"
r = [1].each_with_object(s) { |i, acc| acc }
r << "!"
p s
p r
