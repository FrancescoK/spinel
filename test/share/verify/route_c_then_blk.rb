s = +"abc"
t = s
s.then { |x| x << "!" }
p s
p t
