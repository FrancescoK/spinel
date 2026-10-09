s = +"abc"
r = s.each_char { |c| c }
r << "!"
p s
