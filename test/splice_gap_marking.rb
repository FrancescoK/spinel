# A splice, a range write, insert and fill whose start lands past the end pad
# the gap with nil, which an Integer or Float array holds as its sentinel
# (#6208). The array is marked as able to hold nil unless the start is
# provably in range, so the readers that pick their box by that mark (a lazy
# map, zip, product, a splat into a mixed literal, include?, sum, count) read
# the gap as nil. A start computed at run time was taken as in range and the
# gap read as a number. A literal start at or below 0, the array's own size
# and `size - k` stay unmarked.
i = ARGV.size + 3
y = [nil, 1][ARGV.size]

a = [1]
a[i, 0] = [2]
p a.lazy.map { |e| e.nil? }.to_a, (a.sum rescue $!.class)

c = [1.5]
c[i..i] = [2.5]
p c.include?(nil), c.index(nil), c.zip([1, 2, 3, 4]).map { |x, _| x.nil? }

d = [1]
d.insert(i, 5)
p d.count(nil), (d.sum rescue $!.class)

e = [1]
e.fill(7, i, 1)
p [*e, "x"].map(&:nil?)

f = [1.5]
f.fill(i, 1) { |k| k * 0.5 }
p f.product([0]).map { |x, _| x.nil? }

r = (i..i)
g = [1]
g[r] = [3]
p g.count(nil), (y || g).include?(nil), ((y || g).sum rescue $!.class)

h = [1, 2, 3]
h[-1, 1] = [9]
h[h.size, 0] = [4]
h[h.size - 1, 1] = [5]
h[0..1] = [7]
h[..0] = [8]
h.insert(-1, 6)
h.fill(0, 0, 1)
p h, h.include?(nil), h.sum
