s = +"abc"
r = s.scan(/b/) { |m| m }
r << "!"
p s
p r
