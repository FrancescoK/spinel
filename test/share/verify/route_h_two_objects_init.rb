class K
  def initialize(v) = (@v = v)
  def v = @v
  def bang = @v << "!"
end
k1 = K.new(+"a")
k2 = K.new(k1.v)
k2.bang
p k1.v
