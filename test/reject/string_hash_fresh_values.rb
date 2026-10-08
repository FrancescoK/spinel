# A fresh String stored in a Hash must not silently lose its append.
# spinel: reject-share
# spinel: reject-hash-string
h = {k: +"h"}
h.values.each { |x| x << "!" }
p h
