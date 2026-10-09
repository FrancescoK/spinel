s = +"abc"
t = s
[s].group_by(&:size).each_value { |v| v[0] << "!" }
p s
p t
