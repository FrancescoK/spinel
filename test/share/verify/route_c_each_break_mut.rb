s = +"abc"
t = s
[1].each { break s } << "!"
p s
p t
