s = +"abc"
pr = ->(x, y) { @k = x }; pr.curry[s][1]; r = @k
r << "!"
p s
p r
