s = +"abc"
t = s
s.gsub!(/a/) { $~[0].upcase }
p s
p t
