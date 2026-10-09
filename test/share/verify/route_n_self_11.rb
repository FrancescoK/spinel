s = +"abc"
t = s
s.bytesplice(0, 1, s)
p s, t
