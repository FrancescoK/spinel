s = +"abc"
t = s
{}.fetch(:k) { s } << "!"
p s
p t
