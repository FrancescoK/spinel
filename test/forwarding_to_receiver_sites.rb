# `...` forwarded to a call that is not a def named in the program: a method
# on an explicit receiver inside a block, a proc's `.call`, a `__send__` --
# activesupport's Notifications::Fanout#publish and the deprecation proxy's
# method_missing. The forward takes the named form (`*__fwa, &__fwb`, and
# `**__fwk` when a caller passes keywords); such a callee was left alone and
# the `...` refused.
class Sub
  def publish(name, *args) = "#{name}:#{args.inspect}"
  def each_two = (yield 1; yield 2)
  def opts(name, **kw) = "#{name}:#{kw.inspect}"
end
class Fan
  def initialize
    @subs = [Sub.new, Sub.new]
    @delegate = Sub.new
    @proc = proc { |*a| a.size }
  end
  def publish(name, ...) = @subs.map { |s| s.publish(name, ...) }
  def pub_call(...) = @proc.call(...)
  def mm(...) = @delegate.__send__(...)
  def direct(...) = @delegate.publish(...)
  def with_kw(...) = @delegate.opts(...)
end
f = Fan.new
p f.publish(:a, 1, 2)
p f.pub_call(1, 2, 3)
p f.mm(:publish, :c, 4)
f.mm(:each_two) { |x| print x, " " }
puts
p f.direct(:d, 5)
p f.with_kw(:e, x: 1)
