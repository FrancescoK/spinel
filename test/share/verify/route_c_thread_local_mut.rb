s = +"abc"
t = s
Thread.current[:k] = s; Thread.current[:k] << "!"
p s
p t
