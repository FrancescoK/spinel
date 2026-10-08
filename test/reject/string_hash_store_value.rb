# A stored String variable must be refused before the value block appends.
# spinel: reject-share
# spinel: reject-hash-string
s = +"a"
h = {}
h.store(:k, s)
h.each_value { |v| v << "x" }
p s, h[:k]
