# An inline annotation and an --rbs signature for the same method. When they
# agree the program compiles as with either one alone; when they disagree the
# compile stops and names both.
class Meter
  #: (untyped) -> untyped
  def read(x)
    x
  end
end

p Meter.new.read(1)
