# Copying a receiver-rebinding call preserves its chain and source variable.
s = +"a"
r = s << "x" << (s = +"b")
p r, s
s = +"c"
p s.concat(s = +"d")
p s
