# A block `new` hands to an initialize takes its parameters' types from what
# that initialize binds, whatever names the class: a constant, a class
# value, or a class method's own `new`. Only a constant's `new` resolved the
# initialize, so a class value's `k.new { }` and a bare `new { }` in a class
# method typed the block's parameters from the body alone (`t << 1` made one
# an Array), and the initialize handed them an Integer or a String: the
# program crashed. A call that can reach two initialize methods boxes them.

class Keep
  def initialize(&b) = (@b = b)
  def run(x) = @b.call(x)
  def two(x) = @b.call(x, 1)
  def self.make = new { |t| t.upcase }
  def self.selfmake = self.new { |t| t * 3 }
end
class Yld
  def initialize(n) = (@v = yield(n))
  def v = @v
end
k = [Keep][ARGV.size]
p k.new { |t| t + 1 }.run(5)
p k.new { |t| t.upcase }.run("ab")
a = []
k.new { |t| t << 1 }.run(a)
p a
h = {}
k.new { |t| t[:k] = 2 }.run(h)
p h
p k.new { |t, u| [t, u] }.two("s")
p Keep.make.run("cd"), Keep.selfmake.run(7)
y = [Yld][ARGV.size]
p y.new(4) { |x| x * 2 }.v
p y.new(4) { |x| x.to_s * 2 }.v

# two initialize methods a call can reach, each binding its own kind
class Ints
  def initialize = (@v = yield(4))
  def v = @v
end
class Strs
  def initialize = (@v = yield("ab"))
  def v = @v
end
[0, 1].each { |i| p [Ints, Strs][i].new { |x| x * 2 }.v }
class Base
  def initialize(&b) = (@b = b)
  def run = @b.call(3)
  def self.make = new { |t| t + 1 }
end
class Flt < Base
  def initialize(&b) = (@b = b)
  def run = @b.call(2.5)
end
p Base.make.run, Flt.make.run

# The block of a bare `new { }` or a `self.new { }` in a class method is
# lifted as `Keep.new { }`'s is, so the local it writes is shared with the
# class method (master printed 0 for both).
class Acc
  def initialize(&b) = (@b = b)
  def run(x) = @b.call(x)
  def self.bare
    t = 0
    q = new { |x| t += x }
    q.run(3)
    q.run(4)
    t
  end
  def self.with_self
    t = 0
    q = self.new { |x| t += x }
    q.run(5)
    t
  end
end
p Acc.bare, Acc.with_self
