class W
  def initialize(t) = @t = t
  def keep(x, memo) = (puts("#{@t}#{x}"); memo)
end
class Array
  def each_with_object(m) = (each { |x| yield(x, m) }; m)
end
class H
  attr_writer :w
  def initialize = (@w = W.new("a"); @arr = [3, 1])
  def chg = (@w = W.new("b"); [])
  def run
    x = @arr.each_with_object(chg, &@w.method(:keep))
    p x
    p(@arr.each_with_object(chg, &@w.method(:keep)).size)
  end
end
$h = H.new
$h.run
