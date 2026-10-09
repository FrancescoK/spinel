
s = +"abc"
m = [s].map { |v| v }
s << "!"
p(m[0])
p s
