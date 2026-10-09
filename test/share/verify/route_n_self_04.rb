s = +"abc"
t = s
s.sub!(/b/, s)
p s, t
