s = +"abc"
r = s.each_line { |l| l }
r << "!"
p s
p r
