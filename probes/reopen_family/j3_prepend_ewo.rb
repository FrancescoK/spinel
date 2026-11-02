class W
  def initialize(t) = @t = t
  def keep(x, memo) = (puts("#{@t}#{x}"); $h.chg; memo)
end
module M
  def each_with_object(m) = (puts "P"; each { |x| yield(x, m) }; m)
end
class Array
  prepend M
end
class H
  attr_writer :w
  def initialize = (@w = W.new("a"); @arr = [3, 1])
  def chg = (@w = W.new("b"); [])
  def run = p(@arr.each_with_object([], &@w.method(:keep)))
end
$h = H.new
$h.run
