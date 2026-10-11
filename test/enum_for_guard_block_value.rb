# A method that answers `enum_for(:m)` from a top-level
# `return ... unless block_given?` guard answers the Enumerator only when
# called without a block. Called with one, a `self` tail answers the
# receiver, as in CRuby, where it used to be nil.
class Coll
  include Enumerable
  def initialize(*xs) = @xs = xs
  def each
    return enum_for(:each) unless block_given?
    @xs.each { |x| yield x }
    self
  end
  def walk
    return enum_for(:walk) if !block_given?
    @xs.each { |x| yield x }
    nil
  end
end

class Scaled < Coll
  def each
    return to_enum(:each) unless block_given?
    @xs.each { |x| yield x * 10 }
    self
  end
end

class Expander
  attr_reader :args
  def initialize(args) = @args = args
  def process(&b)
    return enum_for(:process) unless block_given?
    @args.uniq.each(&b)
    self
  end
end

c = Coll.new(1, 2, 3)
r = c.each { |x| x }
p r.class, r.equal?(c)
e = c.each
p e.class, e.to_a, e.next, c.each.map { |x| x * 2 }, c.each.with_index.to_a
p c.map { |x| x + 1 }, c.sort.reverse, c.first, c.include?(2)
p c.walk { }, c.walk.to_a
v = [c.each { }, c.each].map(&:class)
p v
held = c.each { }
p held.each.to_a

s = Scaled.new(1, 2)
p s.each { }.class, s.each.to_a

ex = Expander.new(%w[a b a])
seen = []
res = ex.process { |f| seen << f }
p res.equal?(ex), seen, ex.process.to_a
