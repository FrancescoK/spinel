# `||=` / `&&=` on a Float or Bignum ivar or attribute that holds nil.

class Meter
  attr_accessor :rate, :total

  def initialize
    @rate = nil
    @total = nil
    @big = nil
  end

  def set
    @rate = 2.5
    @total = 2**70
    @big = 2**80
    self
  end

  def fill_rate
    @rate ||= 1.5
    @rate
  end

  def rate_or = (@rate ||= 0.5)
  def scale_rate = (@rate &&= @rate * 2)
  def fill_big
    @big ||= 2**65
    @big
  end
  def big_or_small = (@big ||= 7)
  def double_big = (@big &&= @big * 2)
end

m = Meter.new
p m.scale_rate
p m.fill_rate
p m.rate_or
p m.scale_rate
p Meter.new.rate_or
p Meter.new.set.fill_rate

p Meter.new.double_big
p Meter.new.fill_big
p Meter.new.big_or_small
p Meter.new.set.fill_big
p Meter.new.set.double_big

a = Meter.new
a.rate ||= 3.25
a.total ||= 2**66
p [a.rate, a.total]
a.rate &&= 1.0
a.total &&= 1
p [a.rate, a.total]
z = Meter.new
z.rate &&= 1.0
p z.rate
