class Array
  def each_with_object(m) = (each { |x| yield(x, m) }; m)
end
class W
  def initialize(t) = @t = t
  def keep(x, m) = (m << "#{@t}#{x}"; m)
end
class H
  def initialize = (@n = 0; @arr = [3, 1])
  def mk = W.new("w#{@n += 1}")
  def run
    r = []
    3.times { |i| r << @arr.each_with_object([i], &mk.method(:keep)) }
    r
  end
end
p H.new.run
