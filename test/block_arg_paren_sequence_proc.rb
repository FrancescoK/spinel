# A block argument written as a parenthesized sequence ending in a proc
# literal, `&(stmt; proc { ... })`: the proc is the block, after the
# statements run. Nothing followed the literal through the parentheses, so
# its parameters were bound by nothing and read the elements as Integers:
# `{a: 1}.each_with_object([], &(1; proc { |(k, v), m| m << k }))` gave [0].

h = {a: 1}
p h.each_with_object([], &(1; proc { |(k, v), m| m << k }))
p h.each_with_object([], &(nil; proc { |(k, v), m| m << v }))
p h.each_with_object([], &(1; proc { |kv, m| m << kv }))
p h.map(&(1; proc { |k, v| k }))
p [[1, 2]].each_with_object([], &(1; proc { |(x, y), m| m << y }))
p [1, 2].map(&(1; proc { |x| x * 2 }))
p [1, 2].map(&(1; ->(x) { x + 1 }))

# the statements run once, after the receiver and the arguments
$l = []
def lg(x) = ($l << x; x)
p({b: 2}.each_with_object([], &(lg(:seq); proc { |(k, v), m| m << k })))
p lg({c: 3}).each_with_object(lg([]), &(lg(:blk); proc { |(k, v), m| m << v }))
p $l
