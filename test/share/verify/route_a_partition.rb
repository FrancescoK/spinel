s = +"abc"
r = [s].partition { |x| true }[0][0]
r << "!"
p s
p r
