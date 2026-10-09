s = +"abc"
t = s
[s].count { |x| x << "!" }
p s
p t
