# A lambda's bare return or a proc's bare next answers nil to Proc#===, as
# to #call. The boxed slot === reads still held the answer of a call made
# earlier in the body (#8199).
inner = -> { 7 }
f = ->(x) { inner.call; return if x; nil }
g = proc { |x| inner.call; next if x; nil }
p(f === true)
p(g === true)
p(f.call(true))
p(g.call(true))
p(f === false)
h = ->(x) { inner.call; return x * 2 if x > 1; nil }
p(h === 3)
p(h === 1)
