s = +"abc"
t = s
s.then(&:upcase!)
p s
p t
