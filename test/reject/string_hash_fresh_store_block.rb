# A fresh String stored in a Hash must not silently lose its append.
# spinel: reject-share
# spinel: reject-hash-string
h = {}
h.store(:k, +"h") { raise "not called" }
h.each_value { |x| x << "!" }
p h
