s = +"abc"
t = s
[s].index { |x| x << "!" }
p s
p t
