# A `&.` call of a method that yields, on a nil receiver, answers nil and
# runs neither the method nor its block; on an object it runs both.

class K
  attr_reader :n
  def initialize = (@n = 1)
  def pick = yield
  def two(a) = yield(a) + 1
  def plain = (block_given? ? yield : :nob)
  def each2; yield 1; yield 2; end
end
class V
  def kinds
    yield :a
    yield :b
  end
end
class H
  def initialize(k) = (@k = k)
  def go = @k&.pick { @k.n }
end

def tail(k) = k&.pick { :tail }
def ret(k) = k&.pick { return :ret }

def run(k)
  p k&.pick { :v }
  p k&.two(1) { |v| v * 2 }
  k&.pick { p :ran }
  p k&.plain, k&.plain { :blk }
  x = k&.pick { 5 }
  p x
  p [k&.pick { 1 }, k&.two(2) { |v| v }]
  k&.each2 { |i| p i }
  p tail(k), ret(k)
  p "#{k&.pick { :s }}", (k&.pick { 3 }).nil?
  p k&.pick { k&.two(1) { |v| v } }
  p k&.pick { break :b }, k&.pick { next :nx }
  p(k&.pick { 7 } || :dflt)
  p H.new(k).go
end

run(K.new)
run(nil)
[K.new, nil].each { |o| p o&.pick { :e } }
def mk(i) = i == 0 ? V.new : nil
m = mk(0)
m&.kinds { |s| puts s }
n = mk(1)
n&.kinds { |s| puts s }
p(m&.kinds { |s| s }, n&.kinds { |s| s })
