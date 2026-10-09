def keep(x) = (@k = x)
alias keep2 keep
s = +"abc"
method(:keep2).call(s); r = @k
r << "!"
p s
p r
