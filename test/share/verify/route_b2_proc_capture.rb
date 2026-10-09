
s = +"abc"
pr = proc { s }
(pr.call) << "?"
p s
p(pr.call)
