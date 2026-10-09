s = +"abc"
t = s
s.bytesplice(0, 1, "Z")
p s
p t
