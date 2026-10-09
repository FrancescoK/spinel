s = +"abc"
t = s
s.tap(&:upcase!)
p s
p t
