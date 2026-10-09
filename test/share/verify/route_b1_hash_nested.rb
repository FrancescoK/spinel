
s = +"abc"
h = {x: {y: s}}
s << "!"
p(h[:x][:y])
p s
