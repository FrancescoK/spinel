class W
  def initialize(t) = @t = t
  def put(x) = (puts("#{@t}#{x}"); $h.chg; x)
  def put2(x, i) = (puts("#{@t}#{x}/#{i}"); $h.chg; x)
  def add(a, x) = (puts("#{@t}#{x}"); $h.chg; a + x)
end
class Coll
  def initialize = @a = [7]
  def each_with_index = @a.size
end
p Coll.new.each_with_index { |*z| 0 }
class H
  attr_writer :w
  def initialize = (@w = W.new("a"); @arr = [3, 1])
  def chg = (@w = W.new("b"); [])
  def run = p(@arr.each_with_index(&@w.method(:put2)))
end
$h = H.new
$h.run
