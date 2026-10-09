s = +"abc"
t = s
[s].each_entry { |x| x << "!" }
p s
p t
