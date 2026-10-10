# A method's tail answers a bang method's String: the tail has to publish
# the handle, or the caller wraps the bytes into a new String.
class C
  @@v = +"aaa"
  def self.v = @@v
  def self.up = @@v.upcase!
end
p [C.up, C.up, C.v]
$g = +"bb"
p [$g.sub!("x", "y"), $g.sub!("b", "B"), $g]
G = +"cc"
p [G.squeeze!, G.squeeze!("c"), G]
def m5(a) = (a.gsub!("b", "B") if a.is_a?(String))
s = +"abc"
p [m5(s), s, m5(1)]
