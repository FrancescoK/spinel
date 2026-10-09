s = +"abc"
t = s
[s].each_slice(1) { |sl| sl[0] << "!" }
p s
p t
