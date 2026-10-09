s = +"abc"
r = nil; {k: s}.any? { |k, v| r = v }
r << "!"
p s
p r
