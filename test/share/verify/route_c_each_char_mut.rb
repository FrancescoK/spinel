s = +"abc"
t = s
s.each_char { |c| }; s << "!"
p s
p t
