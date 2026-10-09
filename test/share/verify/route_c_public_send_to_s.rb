s = +"abc"
t = s
s.public_send(:to_s) << "!"
p s
p t
