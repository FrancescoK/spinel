s = +"abc"
t = s
pr = proc { s << "!" }; pr.()
p s
p t
