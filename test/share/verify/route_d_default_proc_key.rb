h = Hash.new { |hh, k| k << "!" }
s = +"abc"
h[s]
p s
