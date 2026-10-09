s = +"abc"
t = s
h = Hash.new { |hh, k| k << "!" }; h[s]
p s
p t
