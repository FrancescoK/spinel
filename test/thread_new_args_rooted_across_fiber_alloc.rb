# Thread.new(a, b) { |x, y| }: the argument array and the fiber are sibling
# allocations of one call; the array must stay rooted through the fiber's
# allocation, or a collection there frees it and the next Thread.new is
# handed the same array (two threads then run with one's arguments). The
# padding shifts where the collections land, so under SPINEL_GC_STRESS one
# of the spawns collects inside the fiber's allocation.
# spinel: gc-stress
# spinel: gc-minor
pad = []
ts = (0...48).map do |t|
  (t % 7).times { pad << "p" * (t + 1) }
  lo = t * 100
  hi = lo + 100
  Thread.new(lo, hi) { |a, b| [a, b] }
end
vals = ts.map(&:value)
p vals.uniq.length
p vals == (0...48).map { |t| [t * 100, t * 100 + 100] }
