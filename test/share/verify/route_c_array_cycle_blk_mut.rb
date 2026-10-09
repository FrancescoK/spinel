s = +"abc"
t = s
[s].cycle(1) { |x| x << "!" }
p s
p t
