s = +"abc"
t = s
{k: s}.map { |pr| pr[1] << "!" }
p s
p t
