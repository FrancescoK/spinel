
s = +"abc"
m = [s].select { |v| true }
(m[0]) << "?"
p s
p(m[0])
