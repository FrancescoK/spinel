$h = nil
s = +"abc"
{k: s}.each_value { |v| $h = v }
s << "!"
p($h)
p s
