$h = nil
s = +"abc"
{k: s}.each { |k, v| $h = v }
s << "!"
p($h)
p s
