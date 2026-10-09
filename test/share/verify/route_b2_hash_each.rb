$h = nil
s = +"abc"
{k: s}.each { |k, v| $h = v }
($h) << "?"
p s
p($h)
