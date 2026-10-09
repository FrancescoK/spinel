class K
  attr_accessor :v
  def bang = @v << "!"
end
k1 = K.new
k1.v = +"a"
k2 = K.new
k2.v = k1.v
k2.bang
p k1.v
