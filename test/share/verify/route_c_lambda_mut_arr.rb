s = +"abc"
t = s
ls = [->(x) { x << "!" }]; ls[0].call(s)
p s
p t
