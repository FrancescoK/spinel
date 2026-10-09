s = +"abc"
{}.fetch(s) { |k| k << "!" }
p s
