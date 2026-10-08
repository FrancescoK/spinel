# A String variable on this route must not silently lose its append.
# spinel: reject-share
# spinel: reject-hash-string
s = +"a"
h = {}
h[:k] = s
h.each_pair { |k, q| q.concat("!") }
p s, h
