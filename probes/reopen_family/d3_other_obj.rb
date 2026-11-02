class W
  def initialize(t) = @t = t
  def keep(x, memo) = (puts("#{@t}#{x}"); memo)
end
class G
  def initialize(h) = @h = h
  def poke = @h.chg
end
$g = nil
class Array
  def each_with_object(m) = (each { |x| yield(x, m); $g.poke }; m)
end
class H
  attr_writer :w
  def initialize = (@w = W.new("a"); @arr = [3, 1])
  def chg = (@w = W.new("b"); [])
  def run = p(@arr.each_with_object([], &@w.method(:keep)))
end
$h = H.new
$g = G.new($h)
$h.run
