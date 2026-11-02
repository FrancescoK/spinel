class W
  def initialize(k) = @k = k
  def mul(x) = x * @k
end
class H
  def initialize = @arr = [3, 1]
  def mk(k) = (puts "mk#{k}"; W.new(k))
  def run = [@arr.map(&mk(2).method(:mul)), @arr.select(&mk(1).method(:mul)), @arr.each_with_index.map(&mk(3).method(:mul))]
end
p H.new.run
