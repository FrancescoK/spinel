$h = nil
s = +"abc"
[s].each { |v| $h = v }
s << "!"
p($h)
p s
