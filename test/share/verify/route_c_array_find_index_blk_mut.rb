s = +"abc"
t = s
[s].find_index { |x| x << "!" }
p s
p t
