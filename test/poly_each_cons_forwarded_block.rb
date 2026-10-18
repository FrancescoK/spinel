# each_cons and each_slice on a boxed receiver, handed the block a method
# was given (`def each_cons(n, &blk) = @items.each_cons(n, &blk)`): the
# forward becomes a block that yields each window or slice on, as it does
# for each and map. Left as `&blk`, the boxed Array's arm had no block body
# to run and the call raised NoMethodError.

class Window
  def initialize(items) = @items = items
  def each_cons(n, &blk) = @items.each_cons(n, &blk)
  def each_slice(n, &blk) = @items.each_slice(n, &blk)
end
Window.new(nil) if ARGV.size > 5

w = Window.new([5, 2, 7, 1])
w.each_cons(2) { |a, b| p a + b }
w.each_slice(3) { |s| p s }
w.each_cons(3) do |a, b, c|
  next unless b == 7
  p [a, b, c]
end

def cons(xs, n, &blk) = xs.each_cons(n, &blk)
def slices(xs, n, &blk) = xs.each_slice(n, &blk)
pr = proc { |x, y| p [x, y] }
p cons([1, "a", 3], 2, &pr)
p cons({ a: 1, b: 2 }, 2, &pr)
p slices([1, 2, 3], 2, &pr)
p slices((1..5), 2) { |s| p s.sum }
