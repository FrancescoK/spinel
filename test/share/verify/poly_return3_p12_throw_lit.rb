s = +"ab"
r = catch(:t) { throw :t, [s] }
r[0] << "x"
p s
