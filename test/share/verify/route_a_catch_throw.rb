s = +"abc"
r = catch(:t) { throw :t, s }
r << "!"
p s
p r
