s = +"abc"
t = s
[s, +"q"].sort { |a, b| a << "!" if a.size < 4; a <=> b }
p s
p t
