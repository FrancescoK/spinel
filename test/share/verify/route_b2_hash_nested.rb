
s = +"abc"
h = {x: {y: s}}
(h[:x][:y]) << "?"
p s
p(h[:x][:y])
