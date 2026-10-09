s = +"abc"
t = s
[].delete(s) { s << "!" }
p s
p t
