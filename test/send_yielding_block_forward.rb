# A yielding method reached through send with a block: called directly at
# one site and through a relay forwarding its &blk at another, whose block
# answers another kind (the method's value was typed once, by the first
# site, and the C did not build); and a `...` forwarder into __send__
# called through send with a block (the forwarder lost the block, and the
# yielding method's arm was dropped: NoMethodError).
class Box
  def initialize(v) = @v = v
  def each_twice = (yield @v; yield @v)
  def map_v(&blk) = blk.call(@v)
end
b = Box.new(3)
b.send(:each_twice) { |z| p z }
def relay(o, m, &blk) = o.send(m, &blk)
p relay(b, :map_v) { |x| x + 1 }
p relay(b, :each_twice) { |x| x.to_s + "!" }
p [3, 1, 2].send(:sort_by) { |x| -x }

class Sub
  def publish(name, *args) = "#{name}:#{args.inspect}"
  def each_two = (yield 1; yield 2)
end
class Fan
  def initialize = @delegate = Sub.new
  def mm(...) = @delegate.send(:__send__, ...)
end
f = Fan.new
p f.send(:mm, :publish, :c, 4)
f.send(:mm, :each_two) { |x| print x, " " }
puts
f.mm(:each_two) { |x| print x * 10, " " }
puts
