# A block given to an iterator on a boxed receiver, while one class of the
# program defines the iterator too (here by handing the block on to an
# Integer Array): the Array's own walk yields its elements to the same
# block, so the parameters take any value. They were typed from the class's
# Integer elements alone, and a String element read as 0.

class Node
  def initialize(e) = @e = e
  def each_cons(n, &blk) = @e.each_cons(n, &blk)
  def each_slice(n, &blk) = @e.each_slice(n, &blk)
end

def pick(a, i) = a[i]
v = pick([[3, "a", 2], Node.new([1, 2, 3])], 0)
v.each_cons(2) { |t1, t2| p [t1, t2] }
v.each_slice(2) { |s| p s }
w = pick([[3, "a", 2], Node.new([1, 2, 3])], 1)
w.each_cons(2) { |t1, t2| p [t1, t2] }
w.each_slice(2) { |s| p s }
