class W
  def initialize(t) = @t = t
  def put(x) = (puts("#{@t}#{x}"); $h.chg; x)
  def put2(x, i) = (puts("#{@t}#{x}/#{i}"); $h.chg; x)
  def add(a, x) = (puts("#{@t}#{x}"); $h.chg; a + x)
end
class Array
  def inject(a) = (i = 0; while i < size; a = yield(a, self[i]); i += 1; end; a)
end
class H
  attr_writer :w
  def initialize = (@w = W.new("a"); @arr = [3, 1])
  def chg = (@w = W.new("b"); [])
  def run = p(@arr.inject(0, &@w.method(:add)))
end
$h = H.new
$h.run
