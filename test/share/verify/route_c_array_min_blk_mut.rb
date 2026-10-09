s = +"abc"
t = s
[s, +"q"].min { |a, b| a << "!"; 0 }
p s
p t
