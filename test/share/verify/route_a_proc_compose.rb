s = +"abc"
pr = ->(x) { @k = x } >> ->(y) { y }; pr.call(s); r = @k
r << "!"
p s
p r
