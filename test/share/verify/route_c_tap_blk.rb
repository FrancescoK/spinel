s = +"abc"
t = s
s.tap { |x| x << "!" }
p s
p t
