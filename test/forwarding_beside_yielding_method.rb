# Two `...` forwarders to the same *args callee, with an unrelated yielding
# method defined after them. Rewriting the first forwarder appends its new
# `*` parameter at the end of the node table; the yield check for the
# second forwarder's shape must not sweep the node-id range in between (which
# holds the neighbour's `yield`) and call the first forwarder block-taking.

class Sub
  def publish(name, *args) = "sub #{name} #{args.inspect}"
end
class Timed
  def initialize(d) = @delegate = d
  def publish(...) = @delegate.publish(...)
end
class Evented
  def initialize(d) = (@delegate = d; @can = true)
  def publish(...)
    if @can
      @delegate.publish(...)
    end
  end
end
class Fan
  def initialize = @subs = [Sub.new, Timed.new(Sub.new), Evented.new(Sub.new)]
  def listeners_for(name) = @subs.select { |s| name != :none }
  def guard(listeners)
    listeners.each do |s|
      yield s
    end
    listeners
  end
  def publish(name, ...)
    listeners_for(name).map { |s| s.publish(name, ...) }
  end
end
fan = Fan.new
p fan.publish(:a, 1, 2)
p fan.publish(:b)
p fan.guard([1, 2]) { |x| print x }
