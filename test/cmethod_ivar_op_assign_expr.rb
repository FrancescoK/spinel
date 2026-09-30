# An ivar operator-assign or or-assign in EXPRESSION position (an endless
# def's body, a return value, a call argument) inside a method that runs on
# the class object -- `def self.m`, or a module method the class `extend`s --
# stores to the class-level ivar (civ_<Class>_x), as the statement form and
# the plain write already did; it rendered `self->iv_x` on an sp_Class.
module Tally
  def bump = @count += 1
  def seed = (@count ||= 5)
  def dbl = (@count &&= @count * 2)
  def count = @count
end
class Widget
  @count = 10
  extend Tally
end
Widget.bump
p Widget.bump
p Widget.seed
p Widget.dbl
p Widget.count

class Meter
  @n = 1
  @name = nil
  def self.tick = @n += 2
  def self.label = (@name ||= "m#{@n}")
  def self.report(x) = x
end
p Meter.tick
p Meter.report(Meter.tick)
p Meter.label
p Meter.label
