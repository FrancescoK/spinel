s = +"abc"
r = {k: s}.each_with_object([]) { |(k, v), acc| acc << v }[0]
r << "!"
p s
p r
