s = +"abc"
t = s
[s].max_by { |x| x << "!"; 1 }
p s
p t
