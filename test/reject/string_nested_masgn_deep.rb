# This route would append to a copy of the caller's String.
# spinel: reject-share
a = +"a"
((x, y), z), w = [[a, 1], 2], 3
x.upcase!
p a
