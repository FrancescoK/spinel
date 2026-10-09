s = +"abc"
t = s
[s].each_cons(1) { |sl| sl[0] << "!" }
p s
p t
