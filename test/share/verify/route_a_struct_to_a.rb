S = Struct.new(:a)
s = +"abc"
r = S.new(s).to_a[0]
r << "!"
p s
p r
