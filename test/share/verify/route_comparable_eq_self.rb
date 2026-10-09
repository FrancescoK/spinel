class W
  include Comparable
  def initialize(b) = (@b = b)
  def <=>(o) = (@b << "z"; 0)
end
@b = +"a"
w = W.new(@b)
w == w
p @b
