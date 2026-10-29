# Each selected method supplies its defaults while super forwards a block.
module BlockDefaultsLayer
  def m(a, b = 2, &blk) = "L " + super(a * 10, b) { |x| blk.call(x) + 100 }
end
class BlockDefaultsVoice
  def m(a, b = 3) = "k#{a},#{b},#{yield(1)}"
end
def call(k) = k.m(1) { |x| x + 1 }
k = BlockDefaultsVoice.new
p call(k)
class BlockDefaultsVoice; prepend BlockDefaultsLayer; end
p call(k)
p k.m(4, 5) { |x| x * 2 }

def capture_block_method(k) = k.method(:m)
p capture_block_method(k).call(4, 5) { |x| x * 2 }
