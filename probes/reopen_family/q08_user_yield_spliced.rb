class C
  def initialize = @a = [3, 1]
  def walk = (@a.each { |x| yield x }; :done)
end
class W
  def initialize(t) = @t = t
  def put(x) = puts("#{@t}#{x}")
end
class H
  def initialize = (@w = W.new("a"); @c = C.new)
  def chg = (@w = W.new("b"); 0)
  def run = p(@c.walk(&(chg; @w).method(:put)))
end
H.new.run
