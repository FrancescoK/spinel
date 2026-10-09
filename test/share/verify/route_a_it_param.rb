s = +"abc"
r = nil; [s].each { r = it }
r << "!"
p s
p r
