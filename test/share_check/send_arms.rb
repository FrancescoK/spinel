# A dynamic send has one arm per candidate method. An arm whose method needs
# an argument raises ArgumentError for this call and never answers: it
# declares itself. The arms that answer the receiver's String (bang methods,
# to_s, itself, +@, and capitalize of an empty one) are boxed as its handle; an
# arm that only reads the receiver's bytes reads them. None reports.
s = +"abc"
t = s
m = [:upcase!, :downcase!].first
s.send(m)
p s
p t
