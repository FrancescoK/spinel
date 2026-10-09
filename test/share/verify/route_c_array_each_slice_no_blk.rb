s = +"abc"
t = s
[s].each_slice(1).to_a[0][0] << "!"
p s
p t
