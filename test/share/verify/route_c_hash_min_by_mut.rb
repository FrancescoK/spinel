s = +"abc"
t = s
{k: s}.min_by { 1 }[1] << "!"
p s
p t
