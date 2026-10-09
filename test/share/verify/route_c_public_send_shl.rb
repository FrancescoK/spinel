s = +"abc"
t = s
s.public_send(:<<, "!")
p s
p t
