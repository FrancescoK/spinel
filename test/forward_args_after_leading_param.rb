# `def method_missing(name, ...)` forwards only what follows `name`. A call
# forwarding `...` typed the callee's parameters from the enclosing
# method's own counting from the first -- `name` -- where the call itself
# passes from the first forwarded one. Sink#update's splat parameter took
# the method name's type, apart from the Array every call passes it, and
# the C did not compile. (The bare `super` keeps `...` as parameters of the
# method's own; the sends are compiled, not run.)
class Sink
  def update(*hs) = hs.sum
  def level = 1
  def scale(x, by = 2) = x * by
end

class Fan
  def initialize(ls) = @ls = ls
  def method_missing(name, ...)
    if @ls.empty?
      super
    else
      @ls.first.send(name, ...)
    end
  end
end

fan = Fan.new([Sink.new])
if ARGV.size > 99
  p fan.method_missing([:update, :level][ARGV.size], 3, 4)
  p fan.method_missing([:scale, :level][ARGV.size], 5, 3)
end
p Sink.new.update(1, 2)
p Sink.new.scale(4)
p Sink.new.level
