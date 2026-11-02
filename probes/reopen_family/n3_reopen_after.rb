class W
  def initialize(t) = @t = t
  def keep(x, memo) = (puts("#{@t}#{x}"); memo)
end
class H
  def initialize = (@w = W.new("a"); @arr = [3, 1])
  def run = p(@arr.each_with_object([], &@w.method(:keep)))
end
H.new.run
class Array
  def each_with_object(m) = (puts "mine"; yield(first, m); m)
end
H.new.run
