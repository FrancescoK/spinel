s = +"abc"
t = s
s.send(:itself) << "!"
p s
p t
