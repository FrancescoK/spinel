class W
  def initialize(t) = @t = t
  def keep(x, memo) = (puts("#{@t}#{x}"); memo)
end
class Array
  def each_with_object(m) = (each { |x| yield(x, m); $w = W.new("g") }; m)
end
$w = W.new("a")
p [3, 1].each_with_object([], &$w.method(:keep))
