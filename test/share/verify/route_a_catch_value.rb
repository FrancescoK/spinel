s = +"abc"
r = catch(:t) { s }
r << "!"
p s
p r
