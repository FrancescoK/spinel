s = +"abc"
s =~ /(b)/
t = $1
t << "!"
p s, t
