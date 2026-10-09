s = +"abc"
t = s
D = Data.define(:a); D.new(a: s).to_h[:a] << "!"
p s
p t
