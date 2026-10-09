s = +"abc"
t = s
pr = proc { |x| x << "!" }; pr.call(s)
p s
p t
