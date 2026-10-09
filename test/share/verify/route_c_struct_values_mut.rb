s = +"abc"
t = s
S = Struct.new(:a); S.new(s).values[0] << "!"
p s
p t
