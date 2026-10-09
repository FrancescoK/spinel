def keep(x) = ($h = x)
s = +"abc"
method(:keep).call(s)
s << "!"
p($h)
p s
