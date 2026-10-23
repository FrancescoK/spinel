# `Array.new(n, obj)` is an Array of obj's class, as `Array.new(n) { obj }`
# and `[]` + push are: the one fill object sits in every slot (CRuby's
# aliasing), and a method handed an element gets the object, not a box.
class Foo
  attr_accessor :v
  def initialize(v) = @v = v
end

def total(xs)
  t = 0
  xs.each { |x| t += x.v }
  t
end

def bump(f) = f.v += 1

a = Array.new(3, Foo.new(1))
puts a[0].equal?(a[2])
bump(a[0])
puts a[1].v
a << Foo.new(10)
puts total(a)

def sum_bytes(b, n)
  t = 0
  i = 0
  while i < n
    t += b.get_value(:U8, i)
    i += 1
  end
  t
end

bufs = Array.new(0, IO::Buffer.new(0))
k = 0
while k < 3
  b = IO::Buffer.new(4)
  b.set_value(:U8, 0, k + 1)
  bufs << b
  k += 1
end
puts sum_bytes(bufs[2], 4)
puts bufs.size

class Box
  def initialize = @items = Array.new(0, Foo.new(0))
  def add(i) = @items << Foo.new(i)
  def sum = @items.sum { |f| f.v }
end
x = Box.new
3.times { |i| x.add(i) }
puts x.sum

def mk(n) = Array.new(n, Foo.new(4))
m = mk(2)
puts m[1].v + m.size
