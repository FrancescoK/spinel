s = +"abc"
t = s
[s].one? { |x| x << "!" }
p s
p t
