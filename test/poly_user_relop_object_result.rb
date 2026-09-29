# A user comparison operator that answers an object (ruby-vips' Image#> builds
# an image) keeps that answer on a receiver typed poly; the builtin comparison
# folded it to a bool and the next call on it raised.
class Img
  def initialize(v) = @v = v
  def v = @v
  def >(o) = Img.new(@v > o ? 255 : 0)
  def <(o) = Img.new(@v < o ? 255 : 0)
  def ==(o) = o.is_a?(Img) && o.v == @v
end
def mk(x) = x > 2 ? Img.new(x) : [x]
a = mk(5)
p (a > 3).v
p (a < 3).v
b = [Img.new(5), 1].first
p (b > 3).v
p b == Img.new(5)
