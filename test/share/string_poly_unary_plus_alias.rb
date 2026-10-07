# Flag-only: unary + keeps a boxed mutable String's identity with --share-strings.
# The default build copies its value, as it does for a plain assignment.
s = [1, String.new("ab")][1]
t = +(+s)
t << "c"
p s, t, s.equal?(t)

single = [1, String.new("ab")][1]
single_out = +single
single_out << "c"
p single, single_out

wrapped = [1, String.new("ab")][1]
wrapped_out = (+(+(+wrapped)))
wrapped_out << "c"
p wrapped, wrapped_out

chained = [1, String.new("ab")][1]
chained_out = +(middle = +chained)
chained_out << "c"
p chained, middle, chained_out

# Lifting the receiver must leave unary +'s frozen-copy check intact.
frozen = [1, "ab"][1]
frozen_out = +(+frozen)
frozen_out << "c"
p frozen, frozen_out, frozen.frozen?, frozen_out.frozen?

dynamic = [1, String.new("ab")][1]
dynamic.freeze
dynamic_out = +(+dynamic)
dynamic_out << "c"
p dynamic, dynamic_out, dynamic.frozen?, dynamic_out.frozen?

# The same boxed type can contain an Integer, whose + is still its value.
number = [1, String.new("ab")][0]
number_out = +(+number)
number_out << 1
p number, number_out
