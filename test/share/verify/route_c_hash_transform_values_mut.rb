s = +"abc"
t = s
{k: s}.transform_values(&:itself)[:k] << "!"
p s
p t
