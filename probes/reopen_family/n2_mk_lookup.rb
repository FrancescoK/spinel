class W
  def initialize(t) = @t = t
  def keep(x, memo) = (puts("#{@t}#{x}"); memo)
end
class Array
  def each_with_object(m) = (each { |x| yield(x, m) }; m)
end
class H
  def initialize = (@w = W.new("a"); @arr = [3, 1])
  def mk = @w.method(:keep)
  def run = p(@arr.each_with_object([], &mk))
end
H.new.run
