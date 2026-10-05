# The methods of an Array subclass and Array's on its instances (#7449): an
# override that calls super into Array, the subclass's own methods reaching
# Array's on an implicit self, Array's constructor forms when the class has no
# initialize of its own, X[...], the mutators answering the instance itself
# while the other methods answer plain Arrays (to_a a new one), dup and clone
# keeping the class and its instance variables, freeze, and a subclass of the
# subclass.
module Countable
  def twice = size * 2
end

class Names < Array
  include Countable

  def initialize(*names)
    super(names)
    @tag = "names"
  end
  attr_reader :tag

  def shout = map(&:upcase)
  def second = self[1]
  def total_length = sum(&:size)

  def <<(name)
    super(name.downcase)
  end

  def first(n = 1) = super(n).reverse

  def each_initial
    each { |n| yield n[0] }
  end
end

class Short < Names
  def short? = size < 3
end

class Bag < Array; end

Floats = Class.new(Array) do
  def mean = sum / size
end

n = Names.new("Ann", "Bob")
n << "CAROL"
p n, n.class, n.tag, n.shout, n.second, n.total_length, n.twice
p n.first(2), n.last, n.size, n.include?("Bob"), n.index("carol")
n.each_initial { |i| print i }
puts
p n.drop(1).class, n.select { |x| x.size == 3 }.class, n.sort.class, (n + ["x"]).class
p n.to_a.class, n.to_a == n, n.to_ary.equal?(n), n.map(&:size)
p n.push("dan").equal?(n), n.concat(["eve"]).class, n.size
p n.select! { |x| x.size == 3 }.class, n
p n.uniq!, n.compact!
p n.each { }.equal?(n), n.each_with_index { }.class
n.map! { |x| x * 2 }
p n, n.class

d = n.dup
d << "Zed"
c = n.clone
p d.class, d.tag, d.size, n.size, c.class, c == n, c.equal?(n)

n.freeze
p n.frozen?, n.clone.frozen?, n.dup.frozen?
begin
  n << "x"
rescue => e
  p e.class
end

s = Short.new("x")
p s.short?, s.class, s.is_a?(Names), Short.ancestors.take(3), s.twice, Short.superclass

p Bag.new([1, 2]), Bag.new(3) { |i| i * i }, Bag.new(2, 0), Bag.new, Bag[4, 5], Bag[4, 5].class
b = Bag.new
b << "x"
b.push("y")
p b, b.class, b.size

f = Floats.new([1.0, 2.0, 4.5])
p f.mean, f.class, f.max, Floats.superclass

h = {}
h[Bag[1, 2]] = :found
p h[[1, 2]], Bag[1, 2].eql?([1, 2]), [1, 2].eql?(Bag[1, 2]), Bag[1, 2].hash == [1, 2].hash

# the two shapes the subclass refusal used to name (#7075)
class Stack < Array
  def peek = last
end

st = Stack.new
st.push(1)
p st.peek

module Shapes
  class Points < ::Array
  end
end

p Shapes::Points.new.size, Shapes::Points.superclass

# element writes that are no method call reach the instance's own Array
w = Bag.new([1, 2, 3])
w[0] += 10
w[5] ||= 7
w[1], w[2] = 20, 30
w << 4 << 5
w[0..1] = [8]
p w, w.class, w.pop, w.shift, w

# to_a answers a new plain Array of the elements; the walks and the
# combinatorics given a block answer the instance
t = Bag[1, 2]
a = t.to_a
a << 3
p a, a.class, t, t.to_a.equal?(t)
p t.combination(1) { }.equal?(t), t.each_slice(1) { }.equal?(t), t.each_index { }.class
p t.product([3]) { }.class, t.deconstruct.equal?(t)
