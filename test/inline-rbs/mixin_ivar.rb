# spinel: not-cruby -- a false instance variable annotation is refused
# A mixed-in module's instance variable is declared in the module body.
# A false assignment is reported once, as --rbs reports the equivalent
# declaration.
module Box
  # @rbs @x: String

  def fill(v)
    @x = v
  end
  def x = @x
end

class Crate
  include Box
end

b = Crate.new
b.fill(3)
p b.x
