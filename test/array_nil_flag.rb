# A write past the end through an index known only at run time fills the gap
# with nil, which an Integer or Float array holds as its sentinel. Whether a
# whole-array read treats that sentinel as nil used to depend on what analyze
# could prove about the array, and a computed index proves nothing: sum added
# INT64_MIN, max and sort compared it, include?(nil) and count(nil) missed it,
# and a zip, a splat or a lazy map boxed it as a number. The array now carries
# a run-time flag, set where a nil can land and carried to its copies.

def t
  yield
rescue => e
  e.class
end

# the reported shape: Integer, then Float
a = [1, 2]
i = 4 + ARGV.size
a[i] = 4
p a
p a.include?(nil), a.index(nil), a.rindex(nil), a.count(nil)
p t { a.sum }, t { a.max }, t { a.min }, t { a.minmax }, t { a.sort }, t { a.dup.sort! }
p t { a.max(2) }, t { a.min(1) }
p a.zip(a)[2], a.product([0])[2], [*a, "s"][2], a.lazy.map { |e| e.nil? }.to_a
p a.all?, a.any?, a.none?, t { a.pack("q*") }
f = [1.5, 2.5]
f[i] = 4.5
p f, f.include?(nil), f.index(nil), f.count(nil)
p t { f.sum }, t { f.max }, t { f.sort }, f.zip(f)[2], [*f, "s"][3], t { f.pack("d*") }
p t { f.max(2) }, t { f.min(1) }

# the gap made inside a method, read by the caller
def grow(xs, k)
  xs[k] = 9
  xs
end
g = grow([3], ARGV.size + 2)
p g.count(nil), t { g.sum }, t { g.max }

# copies carry the nils: dup, a slice, +, concat, map, select, sort_by, uniq, *
b = [7]
b[ARGV.size + 2] = 8
[b.dup, b[0, 3], b + [1], [0].concat(b), b.map { |e| e }, b.select { true },
 b.sort_by { |e| e.to_s }, b.uniq, b * 2, b.values_at(0, 9), b.first(2), b.reverse].each do |c|
  p [c.count(nil), t { c.sum }, c.include?(nil)]
end
fb = [0.5]
fb[ARGV.size + 2] = 1.5
[fb.dup, fb + [2.5], fb.map { |e| e }, fb.rotate].each { |c| p [c.count(nil), t { c.sum }] }

# compact drops the nils, and with them the flag
c = [1, 2]
c[ARGV.size + 3] = 3
p c.compact.sum, c.compact!, c.sum, c.include?(nil)
d = [1]
d[ARGV.size + 2] = 2
d.delete(nil)
p d, d.sum
e = [5]
e[ARGV.size + 2] = 6
e.clear
e << 1
p e.sum
# an empty array's minmax is [nil, nil]
e.clear
p e.minmax.count(nil), e.minmax.compact

# nils a static mark already saw still read as nil
h = {1 => 2}
m = [1, 2]
m << h[5]
p m.count(nil), t { m.sum }, m.sort_by { |x| x.to_s }.count(nil), m.values_at(0, 2).include?(nil)

# an in-range write opens no gap
w = [1, 2, 3]
w[ARGV.size + 1] = 5
p w.sum, w.max, w.sort, w.include?(nil), w.max(2), w.min(2)
