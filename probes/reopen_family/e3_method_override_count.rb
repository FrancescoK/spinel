class W
  def initialize(t) = @t = t
  def keep(x, memo) = (puts("#{@t}#{x}"); memo)
end
class Array
  def each_with_object(m) = (each { |x| yield(x, m) }; m)
end
class W
  def method(n) = ($n += 1; super)
end
$n = 0
class H
  attr_writer :w
  def initialize = (@w = W.new("a"); @arr = [3, 1])
  def chg = (@w = W.new("b"); [])
  def run = p(@arr.each_with_object([], &@w.method(:keep)))
end
$h = H.new
$h.run
p $n
