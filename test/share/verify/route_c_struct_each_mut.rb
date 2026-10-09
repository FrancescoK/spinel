s = +"abc"
t = s
S = Struct.new(:a); S.new(s).each { |v| v << "!" }
p s
p t
