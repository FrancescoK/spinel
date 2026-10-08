# A Hash value that aliases a live String also needs shared-by-reference
# storage before a chained iterator can append to it.
# spinel: reject-share
s = +"a"
h = { k: s }
h.each_value.with_index { |q, i| q << "!" }
p s
