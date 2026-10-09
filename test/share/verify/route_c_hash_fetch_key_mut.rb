s = +"abc"
t = s
{}.fetch(s) { |k| k << "!" }
p s
p t
