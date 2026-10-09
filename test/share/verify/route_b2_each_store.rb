$h = nil
s = +"abc"
[s].each { |v| $h = v }
($h) << "?"
p s
p($h)
