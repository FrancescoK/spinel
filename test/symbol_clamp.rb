# Symbol is Comparable, so clamp between two Symbols answers the receiver or
# the nearer bound, a Symbol, by the names' order.
p :abc.clamp(:a, :b)
p :abc.clamp(:a, :z)
p :abc.clamp(:b, :z)
p :m.clamp(:m, :m)
s = :zebra
p s.clamp(:apple, :mango)
p s.clamp(:apple, :mango).class
lo = :c
p :a.clamp(lo, :d)
begin
  :m.clamp(:z, :a)
rescue ArgumentError => e
  p e.message
end
p :abc.between?(:a, :b)
