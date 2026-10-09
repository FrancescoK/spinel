# spinel: not-cruby -- annotations the program contradicts are refused
# Each contradiction of an inline annotation is reported at the code that
# contradicts it, as the annotation's, naming the annotation's line: an
# instance variable, a return and a parameter.
class Meter
  # @rbs @reading: Integer

  def initialize
    @reading = "zero"
  end

  #: () -> Integer
  def label = "meter"

  #: (Integer) -> Integer
  def scale(n) = n * 2
end

m = Meter.new
p m.label
p m.scale("two")
