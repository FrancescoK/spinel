class W
  def initialize(t) = @t = t
  def keep(x, memo) = (puts("#{@t}#{x}"); $h.chg; memo)
end
module R
  refine Array do
    def each_with_object(m) = (puts "R"; each { |x| yield(x, m) }; m)
  end
end
using R
class H
  attr_writer :w
  def initialize = (@w = W.new("a"); @arr = [3, 1])
  def chg = (@w = W.new("b"); [])
  def run = p(@arr.each_with_object([], &@w.method(:keep)))
end
$h = H.new
$h.run
