class Array
  def flat_map = (r = []; each { |x| r.concat(yield(x)) }; r)
end
class W
  def initialize(t) = @t = t
  def two(x) = ["#{@t}#{x}", x]
end
class H
  def initialize = (@w = W.new("a"); @arr = [3, 1])
  def chg = (@w = W.new("b"); 0)
  def run = p((chg; @arr).flat_map(&@w.method(:two)))
end
H.new.run
