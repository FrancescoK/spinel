# A bang method on a shared String answers that String, or nil when it
# changed nothing, whatever slot holds it.
class C
  @@v = +"aaa"
  def self.v = @@v
  def self.up = @@v.upcase!
  def self.down = @@v.downcase!
end
$g = +"bb"; G = +"cc"
p [C.up, C.up, C.v], [$g.sub!("x", "y"), $g.sub!("b", "B"), $g]
p [G.squeeze!, G.squeeze!("c"), G]
class D
  def initialize = (@s = +"q")
  def go = [@s.tr!("z", "y"), @s.tr!("q", "Q")]
  attr_reader :s
end
d = D.new; p d.go, d.s
def m5(a) = (a.gsub!("b", "B") if a.is_a?(String))
s = +"abc"; t = +"xyz"
p [m5(s), s, m5(1), m5(t), t]
