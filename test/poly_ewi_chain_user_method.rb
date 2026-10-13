# `x.each_with_index.to_a` on a value that may be an Array or an object of a
# class with its own each_with_index: the object's method is called

class C
  def initialize(a) = (@a = a)
  def each_with_index = @a.each_with_index
end

class D
  def each_with_index
    return to_enum(:each_with_index) unless block_given?
    yield :d, 7
    self
  end
end

def h(x) = x.each_with_index.to_a
p h([3, 4])
p h(C.new([5, 6]))
p h(D.new)
