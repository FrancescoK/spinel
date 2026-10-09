s = +"abc"
t = s
[s].any? { |x| x << "!" }
p s
p t
