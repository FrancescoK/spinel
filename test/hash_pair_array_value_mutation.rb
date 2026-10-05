# An Array a Hash holds is the same object in the [key, value] pairs a
# builtin builds, so a mutation through a pair reaches the Hash.
g = {a: [1], b: [2, 3]}
g.max_by { |k, v| v.size }.last << 4
g.to_a.each { |k, v| v << 5 }
g.first[1] << 6
p g
