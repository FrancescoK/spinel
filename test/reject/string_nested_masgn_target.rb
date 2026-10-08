# This route would append to a copy of the caller's String.
# spinel: reject-share
s = +"s"
(t, u), v = [s, 1], 2
t << "!"
p s
