s = +"abc"
t = s
[s].each_with_object({}) { |x, h| h[x] = x }.each_value { |v| v << "!" }
p s
p t
