s = +"abc"
t = s
[s].sum { |x| x << "!"; 1 }
p s
p t
