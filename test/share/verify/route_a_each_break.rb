s = +"abc"
r = [1].each { break s }
r << "!"
p s
p r
