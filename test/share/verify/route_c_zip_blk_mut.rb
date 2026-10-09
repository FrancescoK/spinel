s = +"abc"
t = s
[s].zip([1]) { |a, b| a << "!" }
p s
p t
