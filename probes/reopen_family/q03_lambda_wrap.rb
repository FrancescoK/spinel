class Array
  def each_with_object(m) = (each { |x| yield(x, m) }; m)
end
class W
  def initialize(t) = @t = t
  def keep(x, m) = (m << "#{@t}#{x}"; m)
end
class H
  def initialize = (@w = W.new("a"); @arr = [3, 1])
  def chg = (@w = W.new("b"); [])
  def run = ->(z) { @arr.each_with_object(chg, &@w.method(:keep)) + [z] }.call(9)
end
p H.new.run
