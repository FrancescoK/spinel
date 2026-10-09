s = +"abc"
t = s
Array.new(1, s)[0] << "!"
p s
p t
