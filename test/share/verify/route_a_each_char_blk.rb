s = +"abc"
r = s.each_char { |ch| ch }
r << "!"
p s
p r
