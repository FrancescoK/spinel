s = +"abc"
t = s
[s].each_with_object({}) { |x, h| h[1] = x }[1] << "!"
p s
p t
