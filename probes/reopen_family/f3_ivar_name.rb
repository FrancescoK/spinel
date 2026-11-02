class W
  def initialize(t) = @t = t
  def keep(x, memo) = (puts("k#{x}"); memo)
  def drop(x, memo) = (puts("d#{x}"); memo)
end
class Array
  def each_with_object(m) = (each { |x| yield(x, m); $h.nm }; m)
end
class H
  def initialize = (@w = W.new("a"); @arr = [3, 1]; @n = :keep)
  def nm = @n = :drop
  def run = p(@arr.each_with_object([], &@w.method(@n)))
end
$h = H.new
$h.run
