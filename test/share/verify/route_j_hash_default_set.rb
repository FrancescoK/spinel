s = +"abc"
h = {}
h.default = s
h[:missing] << "!"
p s
