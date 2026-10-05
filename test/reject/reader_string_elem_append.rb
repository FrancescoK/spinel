class Box
  def initialize = (@s = +"q")
  attr_reader :s
end
k = Box.new
a = []
a << k.s
a[0] << "!"
p k.s, a
