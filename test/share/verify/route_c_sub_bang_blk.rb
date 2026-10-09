s = +"abc"
t = s
s.sub!(/a/) { "Z" }
p s
p t
