s = +"abc"
t = s
[s].none? { |x| x << "!"; false }
p s
p t
