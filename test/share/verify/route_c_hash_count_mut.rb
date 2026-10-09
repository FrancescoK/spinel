s = +"abc"
t = s
{k: s}.count { |k, v| v << "!" }
p s
p t
