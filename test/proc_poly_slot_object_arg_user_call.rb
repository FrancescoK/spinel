# The same through the dispatch pre-arm a user #call brings.

class Foo
  def inspect = "#<Foo>"
end
class Bar
  def inspect = "#<Bar>"
end
class Cal
  def call(a, h = nil) = [:cal, a, h]
end
xs = [Foo.new, Bar.new, 1]
pr = proc { |a, k: 1| [a, k] }
[pr, Cal.new].each do |c|
  xs.each do |x|
    p c.call(x)
    p c.call(x, {k: 2})
  end
end
