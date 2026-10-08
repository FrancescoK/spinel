# A fresh String stored in a Hash must not silently lose its append.
# spinel: reject-share
# spinel: reject-hash-string
def fresh = +"h"
h = {k: fresh}
h.each_value { |x| x << "!" }
p h
