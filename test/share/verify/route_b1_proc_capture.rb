
s = +"abc"
pr = proc { s }
s << "!"
p(pr.call)
p s
