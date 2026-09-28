class Kw
  attr_reader :v
  def initialize(x:)
    @v = yield(x) + 1
  end
end
class Other
  attr_reader :v
  def initialize(other: 0) = (@v = other)
end
k2 = [Other, Kw].first
p k2.new(other: 1) { "text" }.v
k = [Kw, Other].first
p k.new(x: 2) { |n| n * 10 }.v
