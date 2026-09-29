# A class method called with a splat on a Class value held in an ivar, a
# local or a container: `@k.mk(*args)`.

class A
  def initialize(x, y) = @s = x + y
  def s = @s
  def self.mk(x, y) = new(x, y)
  def self.sum(x, y) = x + y
end

class B
  def initialize(x, y) = @s = x * y
  def s = @s
  def self.mk(x, y) = new(x, y)
  def self.sum(x, y, z = 10) = x * y * z
end

class D
  def self.sum(*r) = r.size
end

class H
  def initialize(k) = @k = k

  def run
    args = [3, 4]
    @k.new(*args).s
  end

  def run2
    args = [3, 4]
    @k.mk(*args).s
  end

  def sum(args) = @k.sum(*args)
  def sum1(args) = @k.sum(1, *args)
end

p H.new(A).run
p H.new(B).run
p H.new(A).run2
p H.new(B).run2
p H.new(A).sum([1, 2])
p H.new(B).sum([1, 2])
p H.new(B).sum([1, 2, 3])
p H.new(D).sum([1, 2, 3, 4])
p H.new(A).sum1([5])
p H.new(B).sum1([5, 6])
begin
  p H.new(A).sum([1, 2, 3])
rescue ArgumentError => e
  p e.message
end
k = [A, B][1]
args = [5, 6]
p k.mk(*args).s

# several splats in one call each spread
class SplA
  def self.zero = :a0
  def self.two(x, y) = [:a, x, y]
end
class SplB
  def self.zero = :b0
  def self.two(x, y) = [:b, x, y]
end
class SplH
  def initialize(k) = @k = k
  def run
    e = []
    one = [1]
    [@k.zero(*e, *e), @k.two(*one, *[2])]
  end
end
p SplH.new(SplA).run, SplH.new(SplB).run
