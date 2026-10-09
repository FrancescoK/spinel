s = +"abc"
pr = ->(x, y) { @k = x }
pr.curry[s][1]
@k << "!"
p s
