s = +"abc"
r = {k: s}.flat_map { |k, v| [v] }[0]
r << "!"
p s
p r
