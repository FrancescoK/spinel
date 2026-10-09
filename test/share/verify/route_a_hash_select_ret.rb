s = +"abc"
r = {k: s}.select { |k, v| true }[:k]
r << "!"
p s
p r
