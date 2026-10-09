s = +"abc"
t = s
{k: s}.each { |k, v| v << "!" }
p s
p t
