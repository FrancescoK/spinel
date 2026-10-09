s = +"abc"
t = s
[s].each(&:upcase!)
p s
p t
