# An ivar read only for its truthiness still holds the object written into
# it in a program that registers a finalizer: storing the truthiness would
# drop the reference, and the finalizer would run while the holder still
# has the object.

class Res
  def initialize(n) = @n = n
  def inspect = "Res"
end

class Holder
  def initialize = @res = false
  def inspect = "Holder"
  def take(r) = (@res = r; nil)
  def has? = @res ? 1 : 0
end

def fill(h)
  r = Res.new(1)
  ObjectSpace.define_finalizer(r, proc { puts "finalized" })
  h.take(r)
  nil
end

h = Holder.new
fill(h)
10.times { Array.new(1000) { |i| [i] } }
GC.start
puts "after GC"
p h.has?
