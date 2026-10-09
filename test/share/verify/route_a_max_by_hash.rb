s = +"abc"
r = {k: s}.max_by { |k, v| v.size }[1]
r << "!"
p s
p r
