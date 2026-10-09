s = +"abc"
t = s
[s].reverse_each { |x| x << "!" }
p s
p t
