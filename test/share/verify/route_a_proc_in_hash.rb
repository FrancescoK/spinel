s = +"abc"
h = {m: ->(x) { @k = x }}; h[:m].(s); r = @k
r << "!"
p s
p r
