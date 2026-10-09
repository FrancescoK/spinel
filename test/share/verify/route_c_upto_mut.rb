s = +"abc"
t = s
"a".upto("a") { |x| s << x }
p s
p t
