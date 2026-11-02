class W
  def initialize(t) = @t = t
  def put(x) = (puts("#{@t}#{x}"); $h.chg; x)
  def put2(x, i) = (puts("#{@t}#{x}/#{i}"); $h.chg; x)
  def add(a, x) = (puts("#{@t}#{x}"); $h.chg; a + x)
end
class Array
  def each_with_index = (i = 0; while i < size; yield self[i], i; i += 1; end; self)
end
class H
  attr_writer :w
  def initialize = (@w = W.new("a"); @arr = [3, 1])
  def chg = (@w = W.new("b"); [])
  def run = p(@arr.each_with_index(&@w.method(:put2)))
end
$h = H.new
$h.run
