s = +"abc"
t = s
S = Struct.new(:a); S.new(s).a << "!"
p s
p t
