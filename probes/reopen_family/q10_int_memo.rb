# spinel: int64
class Array
  def each_with_object(m) = (each { |x| yield(x, m) }; m)
end
class W
  def initialize(k) = @k = k
  def keep(x, m) = (m << x * @k; m)
end
class H
  def initialize = (@arr = [3, 1]; @k = 3_000_000_000)
  def run = p(@arr.each_with_object([1], &W.new(@k).method(:keep)))
end
H.new.run
