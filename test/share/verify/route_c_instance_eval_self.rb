s = +"abc"
t = s
s.instance_eval { self << "!" }
p s
p t
