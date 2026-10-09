s = +"abc"
r = {k: s}.filter_map { |k, v| v }[0]
r << "!"
p s
p r
