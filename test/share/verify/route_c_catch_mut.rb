s = +"abc"
t = s
catch(:x) { s << "!"; throw :x }
p s
p t
