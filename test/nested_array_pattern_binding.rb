# spinel: share
# spinel: gc-minor
# spinel: gc-stress
# Nested pattern leaves must be boxed before Integer shift is inferred.
case [[1]]; in [[a]]; end
p a << 2
case [0, [3, 4]]; in [*, [b, c]]; end
p b << 1
p c << 2
case [[[5]]]; in [[[d]]]; end
p d << 1
case [0, [6, 7]]; in [*, [e, f] => pair]; end
p e << 1
p f << 1
p pair
