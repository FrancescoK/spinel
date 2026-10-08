# A Hash store through a box widens the Hash literals the receiver can be
# (#7942), but a method whose return an --rbs signature pins to a concrete
# Hash keeps the variant it declares: widening its literal left the C function
# returning sp_StrStrHash * a sp_PolyPolyHash * (#7987).
# spinel: rbs-seed-run
class Widget
  def headers
    { "a" => "b" }
  end
end

class Gadget
  def headers
    { 1 => 2 }
  end
end

p Widget.new.headers
[Gadget.new, Widget.new][ARGV.size].headers[:k] = 1
g = Gadget.new
h = g.headers
h[:z] = 9
p h
