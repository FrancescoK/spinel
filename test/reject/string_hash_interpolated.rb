# A fresh String stored in a Hash must not silently lose its append.
# spinel: reject-share
# spinel: reject-hash-string
n = 1
h = {k: "h#{n}"}
h.each_value { |x| x << "!" }
p h
