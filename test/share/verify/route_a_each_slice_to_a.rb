s = +"abc"
r = [s].each_slice(1).to_a[0][0]
r << "!"
p s
p r
