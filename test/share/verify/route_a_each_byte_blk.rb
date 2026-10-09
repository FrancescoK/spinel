s = +"abc"
r = s.each_byte { |b| b }
r << "!"
p s
p r
