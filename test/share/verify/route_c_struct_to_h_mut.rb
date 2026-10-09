s = +"abc"
t = s
S = Struct.new(:a); S.new(s).to_h[:a] << "!"
p s
p t
