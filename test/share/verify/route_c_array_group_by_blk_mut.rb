s = +"abc"
t = s
[s].group_by { |x| x << "!" }
p s
p t
