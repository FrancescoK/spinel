s = +"abc"
r = {k: s}.rassoc(s)[1]
r << "!"
p s
p r
