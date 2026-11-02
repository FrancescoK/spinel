class W
  def initialize(t) = @t = t
  def keep(x, memo) = (puts("#{@t}#{x}"); $h.chg; memo)
end
class Coll
  def each_with_object(m) = (yield(9, m); m)
end
p Coll.new.each_with_object([]) { |x, m| m << x }
class H
  attr_writer :w
  def initialize = (@w = W.new("a"); @arr = [3, 1])
  def chg = (@w = W.new("b"); [])
  def run = p(@arr.each_with_object([], &@w.method(:keep)))
end
$h = H.new
$h.run
