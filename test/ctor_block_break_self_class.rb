# A `break` in the block of `self.class.new` in an instance method leaves
# the `new` with its value, one and two calls down, and on a Class.new class.

class Maker
  attr_reader :b
  def initialize = (@b = block_given? ? yield : :none)
  def mk(c) = self.class.new { break :inst if c; 4 }
  def go(c) = mk(c)
  def tail = self.class.new { break :tail }
end
class Plain
  attr_reader :b
  def initialize; @b = yield if block_given?; end
  def mk = self.class.new { break :plain }
end
K = Class.new do
  attr_reader :b
  def initialize = (@b = block_given? ? yield : :none)
  def mk = self.class.new { break :anon }
end

p Maker.new.mk(true), Maker.new.mk(false).b, Maker.new.go(true), Maker.new.go(false).b
p Maker.new.tail, [Maker.new.tail, Maker.new.mk(false).b]
p Plain.new.mk, K.new.mk, K.new { 5 }.b
