s = +"abc"
t = s
[s].sort_by(&:size)[0] << "!"
p s
p t
