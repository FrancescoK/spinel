class W
  def initialize(t) = @t = t
  def keep(x, memo) = (puts("#{@t}#{x}"); memo)
end
class Coll
  def initialize = @a = [3, 1]
  def each_with_object(m) = (@a.each { |x| yield(x, m) }; m)
end
class H
  attr_writer :w
  def initialize = (@w = W.new("a"); @arr = [3, 1])
  def chg = (@w = W.new("b"); [])
  def run = p(Coll.new.each_with_object(chg, &@w.method(:keep)))
end
$h = H.new
$h.run
