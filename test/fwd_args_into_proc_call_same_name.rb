# `def call(...) = @block.call(...)` (io-event's Timers::Handle): the only
# def named call is the forwarder itself, so the target is the proc's call,
# taking the channels the callers use -- positionals of any count, keywords
# and a block -- and a forwarder chained into another one alike.

class Handle
  def initialize(&block) = @block = block
  def call(...) = @block.call(...)
end

class Outer
  def initialize(h) = @h = h
  def call(...) = @h.call(...)
end

h = Handle.new { |a, b| [a, b] }
p h.call(1, 2)
p h.call(3)
kw = Handle.new { |a, k: 0| [a, k] }
p kw.call(1, k: 2)
p kw.call(3)
bl = Handle.new { |a, &b| b ? b.call(a) : :noblk }
p bl.call(4) { |x| x * 10 }
p bl.call(5)
o = Outer.new(Handle.new { |a, b| [a, b] })
p o.call(6, 7)
p o.call(8)
