class K; def self.set(v) = (@@g = v); def self.g = @@g; end
s = +"abc"
K.set(s)
s << "!"
p(K.g)
p s
