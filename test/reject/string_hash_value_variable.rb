# A String variable on this route must not silently lose its append.
# spinel: reject-share
# spinel: reject-hash-string
s = +"a"
h = {k: s}
h.each_value { |q| q << "!" }
p s, h
