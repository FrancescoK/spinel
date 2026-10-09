$h = nil
l = ->(x) { $h = x }
s = +"abc"
l.call(s)
($h) << "?"
p s
p($h)
