# spinel: share
s = +"abc"
t = s
{k: s}.select { true }[:k] << "!"
p s
p t
