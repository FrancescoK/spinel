# `s` is a poly local a String mutator (sub!) runs on, so the String
# written to it is demanded as a fresh handle. That demand was decided
# while @number was still untyped -- the re-narrow re-clears the poly
# ivar and its parameter, and `number` reaches it one binding later --
# so `@number.to_s.strip` read as a String then. Once @number is poly
# again, Num#to_s answers a boxed value and so does strip: the handle is
# built from that value, not from a String it no longer is.
class Num
  def initialize(v) = @v = v
  def to_s = @v
end

class Conv
  def initialize(number) = @number = number

  def convert
    s = @number.is_a?(Float) ? 1 : @number.to_s.strip
    return s unless s.is_a?(String)
    s.sub!(/^-/, "") ? "#{s}-" : s
  end
end

def fmt(number) = Conv.new(number).convert

p fmt(-12)
p fmt(Num.new(" -7 "))
p fmt(1.5)
p Num.new(3).to_s
