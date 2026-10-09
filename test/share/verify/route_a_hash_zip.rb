s = +"abc"
r = {k: s}.zip([1])[0][0][1]
r << "!"
p s
p r
