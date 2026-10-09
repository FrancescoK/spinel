s = +"abc"
r = [s].group_by { |x| 1 }[1][0]
r << "!"
p s
p r
