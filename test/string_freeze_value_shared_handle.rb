# `x.freeze` whose value is used, on a String local that is a shared handle
# (here because `+c` answers c itself, so d is another name for it): the
# handle is frozen in place and the value is the frozen String. The C
# assigned to the handle's value read and did not compile.
# spinel: share
c = +"abc"
d = +c
d << "n"
e = c.freeze
p [c, d, e, e.frozen?, d.frozen?, c.frozen?]
begin
  d << "x"
rescue FrozenError => ex
  p ex.class
end
f = +c.freeze
f << "!"
p [c, f, f.equal?(c)]

class Box
  def initialize = (@s = +"iv")
  def run
    al = @s
    al << "1"
    g = @s.freeze
    [g, @s.frozen?, al.frozen?]
  end
end
p Box.new.run
