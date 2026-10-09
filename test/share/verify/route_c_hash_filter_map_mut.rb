s = +"abc"
t = s
{k: s}.filter_map { |k, v| v }[0] << "!"
p s
p t
