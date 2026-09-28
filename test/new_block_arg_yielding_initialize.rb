# `new(..., &b)` into a yielding initialize runs the initialize when no
# block arrives at run time, and a real proc reaches its yield.
class R
  def initialize(a) = (@v = [a, block_given? ? yield : :none])
  attr_reader :v
  def self.make(x, &b) = new(x, &b)
end
p R.make(1).v
p R.make(1) { :b }.v
p R.new(1, &nil).v
def mk(b = nil) = (k = R; k.new(1, &b).v)
p mk
p mk(proc { :pp })

class Base
  def initialize(a, m = 2) = (@v = [a * m, block_given? ? yield(a) : :none])
  attr_reader :v
end
class Sub < Base
  def self.make(x, &b) = new(x, &b)
end
p Sub.make(3).v
p Sub.make(3) { |z| z + 100 }.v
p [1, 2].map { |i| Sub.make(i).v }
p [1, 2].map { |i| Sub.make(i) { |z| z * 10 }.v }

class Holder
  def initialize(pr = nil) = (@p = pr)
  def build(x) = Base.new(x, 5, &@p).v
end
p Holder.new.build(1)
p Holder.new(proc { |z| [:held, z] }).build(1)

def rec(n, &b)
  return Base.new(n, &b).v if n == 0
  rec(n - 1, &b)
end
p rec(2)
p rec(2) { |z| :r }

class Q
  def initialize(a)
    @a = a
    @b = yield(a) if block_given?
  end
  attr_reader :a, :b
  def self.of(x, &b) = new(x, &b)
  def self.of2(x, &b) = of(x, &b)
end
q = Q.of2(4); p [q.a, q.b]
q = Q.of2(4) { |z| -z }; p [q.a, q.b]

S = Struct.new(:a) do
  def initialize(a) = super(block_given? ? yield : a)
  def self.make(x, &b) = new(x, &b)
end
p S.make(1).a
p S.make(1) { 2 }.a

D = Data.define(:x, :y) do
  def initialize(x:, y: 0) = super(x: x, y: block_given? ? yield : y)
  def self.make(x, &b) = new(x: x, &b)
end
p D.make(1)
p D.make(1) { 9 }

class Anon
  def initialize(a) = (@v = [a, block_given? ? yield : :none])
  attr_reader :v
  def self.make(x, &) = new(x, &)
  def self.deep(n, &b) = n == 0 ? new(n, &b) : deep(n - 1, &b)
  def self.deep2(n, &) = n == 0 ? new(n, &) : deep2(n - 1, &)
end
p Anon.make(1).v
p Anon.make(1) { :a }.v
p Anon.deep(2).v
p Anon.deep(2) { :d }.v
p Anon.deep2(2).v
p Anon.deep2(2) { :d2 }.v
