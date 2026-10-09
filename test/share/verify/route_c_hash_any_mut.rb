s = +"abc"
t = s
{k: s}.any? { |k, v| v << "!" }
p s
p t
