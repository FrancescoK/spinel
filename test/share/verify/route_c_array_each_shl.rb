s = +"abc"
t = s
[s].each { |x| x << "!" }
p s
p t
