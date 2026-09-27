# A forwarder `def m(n, &blk) = target.m(n, &blk)` whose target is boxed, and
# which is itself reached through a boxed receiver, so its proc form is
# emitted: the with-arguments boxed dispatch materialized the shared proc
# straight from the `&blk` node, as if it were a block literal, and refused
# ("proc literal without a block"). The zero-argument dispatch already
# forwarded the real proc; this is the same.
class Engine
  def each_gear(n) = (1..n).each { |g| yield g }
end
class Car
  def initialize(e) = @engine = e
  def engine = @engine
  def spare = [nil, engine].first        # nil at run time, boxed statically
  def each_gear(n, &blk) = engine.each_gear(n, &blk)
  def spare_gears(n, &blk) = spare.nil? ? :none : spare.each_gear(n, &blk)
end
c = Car.new(Engine.new)
c.each_gear(2) { |g| print g }
puts
p c.spare_gears(2) { |g| print g }
[c, nil].each { |x| p x&.spare_gears(3) { |g| print g } }
