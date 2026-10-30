# An object whose ivars are scalars inspects them through their own kinds'
# inspect, as sp_poly_inspect's arm for each would; and the walk does not
# call the computed-ivar inspect when no class sets an ivar by a computed
# name.
# absent: sp_bivar_inspect_into
class Pt
  def initialize(x, y, name, ok, tag, f)
    @x = x; @y = y; @name = name; @ok = ok; @tag = tag; @f = f
  end
  def clear = @y = nil
end
a = Pt.new(1, 2, "a\"b\n", true, :sym, 1.5)
puts a.inspect.sub(/0x\h+/, "X")
a.clear
puts a.inspect.sub(/0x\h+/, "X")
b = Pt.new(-3, 4, "", false, :"odd sym", 1e20)
puts b.inspect.sub(/0x\h+/, "X")
