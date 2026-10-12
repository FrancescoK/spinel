# A typed Array or String indexed by a parameter that one call passes an
# Integer and another a Range: the index is boxed, and the read and the
# store took it as an Integer, raising TypeError where CRuby answers or
# replaces the slice.
class Regs
  def initialize = @values = Array.new(8, 0)
  def [](reg) = @values[reg]
  def []=(reg, v)
    @values[reg] = v
  end
  def values = @values
end
r = Regs.new
r[1] = 5
p r[1]
p r[0..1]
p r[2..]
p r[9..]
p(r[3..4] = 7)
p r.values

class Text
  def initialize = @s = "abcdefgh"
  def [](i) = @s[i]
end
t = Text.new
p t[1]
p t[0..2]
p t[5..]
p t[20..]

class Via
  def initialize = @values = [1.5, 2.5, 3.5]
  def [](reg) = fetch(reg)
  def fetch(reg) = @values[reg]
end
v = Via.new
p v[1]
p v[1..2]
p v[-2..]

class Store
  def initialize
    @s = %w[a b c d]
    @m = [1, "x", 3, 4]
  end
  def put_s(i, v)
    @s[i] = v
    nil
  end
  def put_m(i, v)
    @m[i] = v
    nil
  end
  def show = p(@s, @m)
end
s = Store.new
s.put_s(0, "z")
s.put_s(1..2, "y")
s.put_m(0, 7)
s.put_m(2.., 8)
s.show
