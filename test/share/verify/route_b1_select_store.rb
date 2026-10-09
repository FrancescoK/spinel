
s = +"abc"
m = [s].select { |v| true }
s << "!"
p(m[0])
p s
