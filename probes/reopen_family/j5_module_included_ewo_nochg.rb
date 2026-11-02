class W
  def initialize(t) = @t = t
  def keep(x, memo) = (puts("#{@t}#{x}"); memo)
end
module M
  def each_with_object(m) = (puts "M"; each { |x| yield(x, m) }; m)
end
class Array
  include M
end
class H
  attr_writer :w
  def initialize = (@w = W.new("a"); @arr = [3, 1])
  def chg = (@w = W.new("b"); {z: 1})
  def run = p(@arr.each_with_object(chg, &@w.method(:keep)))
end
$h = H.new
$h.run
