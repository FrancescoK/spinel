# spinel: share
s = +"abc"
t = s
{k: s}.reject { false }[:k] << "!"
p s
p t
