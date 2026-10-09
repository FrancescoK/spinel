s = +"abc"
t = s
{k: s}.find { true }[1] << "!"
p s
p t
