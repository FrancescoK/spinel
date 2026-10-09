s = +"abc"
t = s
s.scan(/a/) { $~.pre_match }; s << "!"
p s
p t
