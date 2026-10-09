s = +"abc"
t = s
s.send(:<<, "!")
p s
p t
