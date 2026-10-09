# spinel: not-cruby -- a false instance variable annotation is refused
# A write in a mixed-in module's method is copied into the class that
# includes it; a false annotation on it is reported once, as --rbs reports
# the equivalent declaration.
module Box
  def fill(v)
    @x = v #: String
  end
  def x = @x
end

class Crate
  include Box
end

b = Crate.new
b.fill(3)
p b.x
