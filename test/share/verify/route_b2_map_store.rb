
s = +"abc"
m = [s].map { |v| v }
(m[0]) << "?"
p s
p(m[0])
