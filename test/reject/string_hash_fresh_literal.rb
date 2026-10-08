# A fresh String stored in a Hash must not silently lose its append.
# spinel: reject-share
# spinel: reject-hash-string
{k: +"h"}.each_value { |x| x << "!"; p x }
