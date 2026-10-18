# A String a Hash holds, read back out through the [key, value] pairs a
# builtin builds and then mutated, is not yet shared by reference: refused,
# not silently appended to a copy.
h = {a: +"w", b: 1}
h.to_a.each { |k, v| v << "@" if v.is_a?(String) }
h.first[1] << "!"
k, v = h.first
v << "?"
h.max_by { |k2, v2| v2.to_s }.last << "#"
h.each { |pair| pair[1] << "%" if pair[1].is_a?(String) }
p h
