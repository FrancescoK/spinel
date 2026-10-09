s = +"abc"
r = nil; {k: s}.each_slice(1) { |sl| r = sl[0][1] }
r << "!"
p s
p r
