class K; def initialize(x) = (@k = x); end
s = +"abc"
r = K.new(s).instance_variable_get("@k")
r << "!"
p s
p r
