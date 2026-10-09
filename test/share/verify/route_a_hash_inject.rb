s = +"abc"
r = {k: s}.inject(nil) { |acc, (k, v)| v }
r << "!"
p s
p r
