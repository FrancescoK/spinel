s = +"abc"
r = {k: s}.min_by(1) { |k, v| 1 }[0][1]
r << "!"
p s
p r
