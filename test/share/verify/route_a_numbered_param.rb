s = +"abc"
r = nil; [s].each { r = _1 }
r << "!"
p s
p r
