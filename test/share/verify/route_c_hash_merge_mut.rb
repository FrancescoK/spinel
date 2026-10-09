s = +"abc"
t = s
{}.merge({k: s})[:k] << "!"
p s
p t
