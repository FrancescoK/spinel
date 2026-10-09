s = +"abc"
t = s
{k: +"x"}.merge({k: s}) { |k, a, b| b }[:k] << "!"
p s
p t
