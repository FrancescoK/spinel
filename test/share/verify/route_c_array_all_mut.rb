s = +"abc"
t = s
[s].all? { |x| x << "!" }
p s
p t
