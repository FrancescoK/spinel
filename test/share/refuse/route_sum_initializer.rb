# spinel: not-cruby
# The initializer is returned unchanged by an empty sum. This result route
# cannot carry its shared handle, so it must not silently return a copy.
s = +"a"
a = []
r = a.sum(s)
r << "!"
p [s, r]
