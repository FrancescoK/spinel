s = +"abc"
r = [s].each_with_index.to_a[0][0]
r << "!"
p s
p r
