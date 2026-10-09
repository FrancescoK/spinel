s = +"abc"
t = s
[s].min_by(&:size) << "!"
p s
p t
