class Array
  def each_with_object(m) = (each { |x| yield(x, m) }; m)
end
class W
  def initialize(t) = @t = t
  def keep(x, m) = (m << "#{@t}#{x}"; m)
end
$w = W.new("a")
def chg = ($w = W.new("b"); [])
p [3, 1].each_with_object(chg, &$w.method(:keep))
p [3, 1].each_with_object([], &W.new("c").method(:keep))
