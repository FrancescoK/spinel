class Array
  def each_with_object(m) = (each { |x| yield(x, m) }; m)
end
class W
  def initialize(t) = @t = t
  def keep(x, m) = (m << "#{@t}#{x}"; m)
end
f = Fiber.new { [3, 1].each_with_object([], &W.new("f").method(:keep)) }
p f.resume
t = Thread.new { [2].each_with_object([], &W.new("t").method(:keep)) }
p t.value
