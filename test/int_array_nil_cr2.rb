# An Integer or Float array reads nil as its sentinel, so every path that
# boxes one of its elements has to box that as nil. Behind a poly receiver,
# `x[i]`, pop, shift, delete_at, a splice into a poly array and a replace
# boxed it as a number (nil? false, NaN for a Float), and pop(n) stopped at a
# nil element. A lazy map over an Integer array did the same. A user method
# named like an array method (concat, push, to_a, first) on an object marked
# nothing: the receiver was asked instead of the method's own array. A slice
# of a nil-carrying array (`a[0, 2]`, `a[0..1]`) came back unmarked, and
# `slice(i)` of a Float array printed NaN. A slice or range write, insert or
# fill starting past the end raised or left the nil gap unmarked, where CRuby
# fills it with nil.
class Grid
  def [](i) = i * 10
  def zzz = 0
end

class Maker
  def concat = [1.0, [2.0][ARGV.size + 5]]
  def push = [1, [2][ARGV.size + 5]]
  def to_a = [3, [4][ARGV.size + 5]]
  def first = [5.0, [6.0][ARGV.size + 5]]
end

b = [1][ARGV.size + 5]
fb = [1.5][ARGV.size + 5]

# poly reads
x = ARGV.size > 5 ? Grid.new : [1, 2, b]
y = ARGV.size > 5 ? Grid.new : [1.5, fb]
p [x[2], x[2].nil?, x[9].nil?, x[0], y[1].nil?, y[7].nil?]
v = x[0..2]
p [v[2].nil?, x.slice(2).nil?]
px = ARGV.size > 5 ? Grid.new : [b, 7, b]
py = ARGV.size > 5 ? Grid.new : [fb, 2.5, fb]
p [px.pop.nil?, px.shift.nil?, py.pop.nil?, py.delete_at(0).nil?]
pz = ARGV.size > 5 ? Grid.new : [3, b]
p pz.shift(5)
pa = [1, "s", 3]
pa[0, 2] = [5, b]
pb = [1, "s"]
pb[0, 1] = [5.5, fb]
pc = ARGV.size > 5 ? Grid.new : [1, "s"]
pc.replace([6, b])
p [pa[1].nil?, pb[1].nil?, pc[1].nil?]
p [1, b].lazy.map { |e| e.nil? }.to_a

# a user method named like an array method
m = Maker.new
a1 = m.concat
a2 = m.push
a3 = m.to_a
a4 = m.first
p [a1.include?(nil), a1.index(nil), a1.join("-"), a2.include?(nil), (a2.sum rescue $!.class)]
p [a3.index(nil), a4.join("-")]

# slices of a nil-carrying array
ia = [b, 7, 8]
fa = [fb, 7.5]
s1 = ia[0, 2]
s2 = fa[0..1]
p [s1.include?(nil), s2.index(nil), fa.slice(0)]

# writes past the end
c1 = [1.0]
c1[3, 0] = [2.0]
p [c1, c1.include?(nil), c1.index(nil)]
c2 = [1]
c2[3, 0] = [2]
p [c2.include?(nil), (c2.sum rescue $!.class)]
c3 = [1.5]
c3[2..3] = [2.5]
c4 = [1]
c4[c4.size + 1, 0] = 5
c5 = [1]
c5.insert(3, 2)
c6 = [1]
c6.fill(9, 2, 1)
c7 = [1.5]
c7.fill(9.5, 2..2)
c8 = [1]
c8.fill(2, 1) { |i| i * 10 }
p [c3.index(nil), c4.count(nil), c5.index(nil), c6.index(nil), c7.index(nil), c8.index(nil)]
c9 = ["a"]
c9[2, 0] = ["b"]
gz = ARGV.size > 5 ? Grid.new : [1]
gz.fill(7, 2, 1)
p [c9, gz, gz[1].nil?]
