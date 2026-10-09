s = +"abc"
t = s
{k: s}.to_a[0][1] << "!"
p s
p t
