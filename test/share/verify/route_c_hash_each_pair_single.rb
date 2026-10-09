s = +"abc"
t = s
{k: s}.each { |pr| pr[1] << "!" }
p s
p t
