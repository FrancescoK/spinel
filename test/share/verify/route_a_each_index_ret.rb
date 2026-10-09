s = +"abc"
a = [s]; r = a.each_index { |i| i }[0]
r << "!"
p s
p r
