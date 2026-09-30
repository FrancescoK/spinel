# A Range answers respond_to?(:empty?) false: Range has no #empty?, though it
# is Enumerable, and the runtime's builtin surface said yes for every
# Enumerable name. The Enumerable names it does have still answer true.
r = (1..3)
p r.respond_to?(:empty?), r.respond_to?(:each), r.respond_to?(:map)
mixed = [r, [1], "s", { a: 1 }]
p mixed.map { |v| v.respond_to?(:empty?) }
p mixed.map { |v| v.respond_to?(:size) }
