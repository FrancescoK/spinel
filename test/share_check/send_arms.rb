# A dynamic send has one arm per candidate method. An arm whose method needs
# an argument raises ArgumentError for this call and never answers: it
# declares itself. The arms that answer a String's own bytes (bang methods,
# to_s, itself) are boxed as bytes, and stay reported.
s = +"abc"
t = s
m = [:upcase!, :downcase!].first
s.send(m)
p s
p t
