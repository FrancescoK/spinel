s = +"abc"
t = s
m = [:upcase!, :downcase!].first; s.send(m)
p s
p t
