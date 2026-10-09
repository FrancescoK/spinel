s = +"abc"
t = s
S = Struct.new(:a); S.new(s).to_a[0] << "!"
p s
p t
