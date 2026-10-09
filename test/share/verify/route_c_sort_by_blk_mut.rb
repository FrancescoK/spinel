s = +"abc"
t = s
[s].sort_by { |x| x << "!"; 1 }
p s
p t
