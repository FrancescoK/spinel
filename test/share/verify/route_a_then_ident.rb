s = +"abc"
r = s.then { |x| x }
r << "!"
p s
p r
