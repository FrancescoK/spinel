s = +"abc"
r = {k: s}.group_by { |k, v| 1 }[1][0][1]
r << "!"
p s
p r
