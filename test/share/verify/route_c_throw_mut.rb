s = +"abc"
t = s
catch(:t) { throw :t, s } << "!"
p s
p t
