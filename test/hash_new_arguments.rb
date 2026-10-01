# Hash.new takes a default or a block, not both, and the one keyword
# `capacity:`, which only sizes the table: CRuby raises ArgumentError for an
# unknown keyword, then for a default beside a block, after the arguments
# run. Spinel took a keyword hash for the default (so a missing key read
# {capacity: 10}), dropped the default beside a block, and found no method
# for an unknown keyword.
p(begin; Hash.new(5) { 0 }; rescue ArgumentError => e; [e.class, e.message]; end)
p(begin; Hash.new(nil) { 0 }; rescue ArgumentError => e; [e.class, e.message]; end)
p(begin; Hash.new(unknown: true); rescue ArgumentError => e; [e.class, e.message]; end)
p(begin; Hash.new(1, unknown: true); rescue ArgumentError => e; [e.class, e.message]; end)
p(begin; Hash.new(unknown: true) { 0 }; rescue ArgumentError => e; [e.class, e.message]; end)
p(begin; Hash.new(a: 1, b: 2); rescue ArgumentError => e; [e.class, e.message]; end)
p(begin; Hash.new(1, a: 1) { }; rescue ArgumentError => e; [e.class, e.message]; end)
p(begin; Hash.new(capacity: 1, x: 2); rescue ArgumentError => e; [e.class, e.message]; end)
$ran = []
def arg(v) = ($ran << v; v)
p(begin; Hash.new(arg(5)) { 0 }; rescue ArgumentError => e; [e.class, e.message]; end)
p(begin; Hash.new(arg(6), bad: arg(7)); rescue ArgumentError => e; [e.class, e.message]; end)
p $ran
h = Hash.new(capacity: 10)
p h, h[:x]
h[:a] = 1
p h
d = Hash.new(5, capacity: 3)
p d[:x]
n = 4
e = Hash.new(capacity: n) { |hh, k| hh[k] = k.to_s * 2 }
p e[:ab], e
f = Hash.new({a: 1})
p f[:z]
l = -> { Hash.new(unknown: true) }
p(begin; l.call; rescue ArgumentError => e; [e.class, e.message]; end)
