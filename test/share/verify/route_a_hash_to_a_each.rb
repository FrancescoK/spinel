s = +"abc"
r = nil; {k: s}.to_a.each { |pr| r = pr[1] }
r << "!"
p s
p r
