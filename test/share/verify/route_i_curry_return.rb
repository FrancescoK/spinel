f = ->(a, b) { a }
s = +"abc"
t = f.curry[s][1]
t << "!"
p s
