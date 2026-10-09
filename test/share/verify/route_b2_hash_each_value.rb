$h = nil
s = +"abc"
{k: s}.each_value { |v| $h = v }
($h) << "?"
p s
p($h)
