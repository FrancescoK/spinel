s = +"abc"
Thread.current[:k] = s; r = Thread.current[:k]
r << "!"
p s
p r
