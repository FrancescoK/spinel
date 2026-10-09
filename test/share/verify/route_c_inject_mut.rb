s = +"abc"
t = s
[s].inject { |a, b| a } << "!"
p s
p t
