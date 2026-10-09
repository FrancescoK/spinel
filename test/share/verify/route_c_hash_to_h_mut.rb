s = +"abc"
t = s
{k: s}.to_h { |k, v| [k, v] }[:k] << "!"
p s
p t
