# The parameter of an each walk over an array of one class binds the element
# class only where nothing else writes it; every other shape stays boxed.
class P
  attr_reader :v
  def initialize(v) = @v = v
end
class Q
  def v = 9
end
class Bag
  attr_reader :n
  def initialize(n) = @n = n
  def each = @n.times { |i| yield i }
end
class Tally
  include Enumerable
  def initialize(*a) = @a = a
  def each(&b) = @a.each(&b)
end

xs = [P.new(1), P.new(2), P.new(3)]
t = 0
xs.each { |x| t += x.v }
xs.reverse_each { |x| t = t * 10 + x.v }
xs.each_entry { |x| t += x.v }
xs.each_with_index { |x, i| t += x.v * i }
p t

# a nested block writes the parameter
xs.each { |x| [1].each { x = nil }; p x }
# the body reassigns it
xs.each { |x| p x.v; x = "s"; p x }
# a lambda captures it
ls = []
xs.each { |x| ls << -> { x.v * 10 } }
p ls.map(&:call)
# the same name in a block that is not a walk
def f(xs)
  t = 0
  xs.each { |x| t += x.v }
  [1, "a"].each { |x| p x }
  t
end
p f(xs)
# two classes in one array
ys = [P.new(1), Q.new]
ys.each { |y| p y.v }
ys.each_with_index { |y, i| p [y.v, i] }
# the array gains a nil
zs = [P.new(4)]
zs.each { |z| p z.v }
zs << nil
zs.each { |z| p z.nil? ? 0 : z.v }
# next, break and each's own value
r = xs.each { |x| next if x.v == 2; break x.v * 100 if x.v == 3; p x.v }
p r
p xs.reverse_each { |x| x }.size
# an element class with its own each, and an Enumerable one
bags = [Bag.new(2), Bag.new(3)]
s = 0
bags.each { |b| b.each { |i| s += i + b.n } }
p s
ts = [Tally.new(3, 1, 2), Tally.new(5)]
ts.each { |tl| p [tl.sort, tl.min, tl.include?(5), tl.count] }
