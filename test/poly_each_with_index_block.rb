# each_with_index / each_index with a block on a value that may be an Array
# or an object of a class with its own method of the name

class C
  def initialize(a) = (@a = a)
  def each_with_index(*args, &blk) = @a.each_with_index(*args, &blk)
  def each_index
    @a.size.times { |i| yield i }
    self
  end
end

def f(x)
  x.each_with_index do |v, i|
    next if i == 1
    p [v, i]
  end
  nil
end
f(C.new([1, 2, 3]))
f([4, 5, 6])

def g(x)
  x.each_index { |i| print i, " " }
  puts
end
g([7, 8])
g(C.new([9]))

