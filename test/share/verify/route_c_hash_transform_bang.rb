s = +"abc"
t = s
{k: s}.transform_values!(&:upcase!)
p s
p t
