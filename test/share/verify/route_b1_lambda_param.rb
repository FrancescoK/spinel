$h = nil
l = ->(x) { $h = x }
s = +"abc"
l.call(s)
s << "!"
p($h)
p s
