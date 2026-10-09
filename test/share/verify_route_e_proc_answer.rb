# spinel: share
s = +"abc"
pr = proc { s }
pr.call << "?"
p s
