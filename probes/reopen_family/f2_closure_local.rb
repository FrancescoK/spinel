class W
  def initialize(t) = @t = t
  def keep(x, memo) = (puts("#{@t}#{x}"); memo)
end
class Array
  def each_with_object(m) = (each { |x| yield(x, m); $ch.call }; m)
end
def run
  w = W.new("a")
  $ch = -> { w = W.new("l") }
  p [3, 1].each_with_object([], &w.method(:keep))
end
run
