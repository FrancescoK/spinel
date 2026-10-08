# A fresh String stored in a Hash must not silently lose its append.
# spinel: reject-share
# spinel: reject-hash-string
h = {k: +"h"}
h.each_pair { |k, x| x << "!" }
p h
