class Coll
  def initialize_states(obj, &blk)
    @blk = blk
    run
    obj
  end
  def run = @blk.call
end

class Base
  def initialize(*args) = (@args = args)
  attr_reader :args
end

class A < Base
  def initialize(a, b) = Coll.new.initialize_states(self) { super; nil }
end

class R < Base
  def initialize(*rest) = Coll.new.initialize_states(self) { super; nil }
end

class N < Base
  def initialize(*) = Coll.new.initialize_states(self) { super; nil }
end

class Runner
  def initialize(&blk) = (@blk = blk)
  def run = @blk.call
end

class P
  def m(x, k: 1, &b) = [x, k, b ? b.call : nil]
  def kr(x, **opts) = [x, opts]
  def bl(x, &b) = [x, b.call]
  def pos(a, b = 2) = [a, b]
  def self.cm(a, *r) = [a, r]
end

class C < P
  def m(x, k: 1, &b) = Runner.new { super }.run
  def kr(x, **) = Runner.new { super }.run
  def bl(x, &) = Runner.new { super }.run
  def pos(a, b = 2)
    pr = Runner.new { super }
    a *= 10
    pr.run
  end
  def self.cm(a, *r) = Runner.new { super }.run
end

module Twice
  def tw(a) = Runner.new { super }.run
end

class T
  prepend Twice
  def tw(a) = a * 2
end

S = Struct.new(:a, :b) do
  def initialize(a, b)
    Runner.new { super; nil }.run
  end
end

class E < StandardError
  def initialize(msg)
    Runner.new { super; nil }.run
  end
end

p A.new(1, 2).args
p R.new(3).args
p N.new(4, 5).args
c = C.new
p c.m(1)
p c.m(2, k: 3) { :blk }
p c.kr(4, z: 5)
p c.bl(6) { :b }
p c.pos(1)
p c.pos(2, 3)
p C.cm(1, 2, 3)
p T.new.tw(7)
p S.new(8, 9).to_a
p E.new("boom").message
