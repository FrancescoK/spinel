s = +"abc"
r = nil; {k: s}.each_with_index { |pr, i| r = pr[1] }
r << "!"
p s
p r
