# String(obj) answers obj.to_s, which answers @x itself, s. The answer was
# a copy and s stayed "abc": refused, not compiled wrong.
class K
  def initialize(x) = (@x = x)
  def to_s = @x
end
s = +"abc"
String(K.new(s)) << "!"
p s
