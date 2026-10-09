s = +"abc"
r = {k: s}.partition { |k, v| true }[0][0][1]
r << "!"
p s
p r
