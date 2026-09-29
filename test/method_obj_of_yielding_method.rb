# A Method object for a method that yields, or that forwards its block to
# one that does (a `new` into a yielding initialize among them).

class R
  def initialize(a, k: 1) = (@v = [a, k, block_given? ? yield(a) : :none])
  attr_reader :v

  def self.make(x, k: 2, &) = new(x, k: k, &)
  def self.sy(a) = [a, block_given? ? yield : :none]
  def self.sf(a, &) = sy(a, &)
  def y(a) = [a, block_given? ? yield : :none]
  def tw(a) = yield(a) * 2

  def each_two
    yield 1
    yield 2
  end
end

module M
  def self.my(a) = block_given? ? yield(a) : :none
  def im(a) = block_given? ? yield(a) : :none
end

class Q
  include M
end

m = R.method(:make)
o = m.call(5)
p o.v
o = m.call(6, k: 3) { |a| a + 1 }
p o.v
o = m.call(7, &->(a) { a * 10 })
p o.v
p m.arity
p m.name
p R.new(0).y(1) { 2 }
p R.new(0).method(:y).call(5)
p R.method(:sy).call(6)
p R.method(:sf).call(8)
p R.method(:sf).call(9) { 1 }
p R.new(0).method(:tw).call(4) { |a| a + 1 }
p R.instance_method(:tw).bind(R.new(0)).call(3) { |a| a }
acc = []
R.new(0).method(:each_two).call { |x| acc << x }
p acc
R.new(0).method(:each_two).to_proc.call { |x| acc << x * 10 }
p acc
begin
  R.new(0).method(:each_two).call
rescue LocalJumpError => e
  p e.class
end
p M.method(:my).call(3) { |x| x * 3 }
p Q.new.method(:im).call(4) { |x| x * 4 }
