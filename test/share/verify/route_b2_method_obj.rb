def keep(x) = ($h = x)
s = +"abc"
method(:keep).call(s)
($h) << "?"
p s
p($h)
