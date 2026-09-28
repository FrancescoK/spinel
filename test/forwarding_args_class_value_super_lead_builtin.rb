# `...` forwarded to a class value's new, through super with leading
# arguments, and into a builtin method

class A
  def initialize(a, b = 7, &blk)
    @v = [a, b, blk ? blk.call : nil]
  end
  attr_reader :v
end
class K
  def initialize(x, k: 0) = (@v = [x, k])
  attr_reader :v
end
class W
  def initialize(*r, **o) = (@v = [r, o])
  attr_reader :v
end
def mk(k, ...) = k.new(...)
cs = [A, K, W]
p mk(cs[0], 1, 2).v
p mk(cs[0], 1).v
p mk(cs[0], 1) { :blk }.v
p mk(cs[1], 1).v
p mk(cs[1], 1, k: 4).v
p mk(cs[2]).v
p mk(cs[2], 1, 2, z: 3).v
class N; end
bare = [N, String]
p mk(bare[0]).class
p mk(bare[1], "ab")
begin
  mk(bare[0], z: 1)
rescue ArgumentError => e
  p e.message
end

class B
  def go(a, b = 2, *r, k: 0, &blk) = [a, b, r, k, blk ? blk.call : nil]
  def bl(a, b) = yield(a + b)
end
class S < B
  def go(a, ...) = super(a, ...)
  def bl(a, ...) = super(a, ...)
end
class T < B
  def go(a, b = 5, ...) = super
  def bl(a, ...) = super
end
class U < B
  def go(a, ...)
    a *= 100
    super
  end
end
p S.new.go(1)
p S.new.go(1, 3, 4, k: 9) { :x }
p S.new.bl(4, 1) { |x| x * 10 }
p T.new.go(1)
p T.new.go(1, 3, 4, k: 9) { :y }
p T.new.bl(2, 3) { |x| x + 1 }
p U.new.go(1, 2)

def fwd(...) = [1, 2].push(...)
p fwd(3, 4)
def fsum(a, ...) = a.sum(...)
p fsum([1, 2], 10)
def fz(h, ...) = h.fetch(...)
p fz({a: 1}, :b, 3)
def fsub(s, ...) = s.sub(...)
p fsub("hello", "l", "L")
def fmap(a, ...) = a.map(...)
p fmap([1, 2]) { |x| x * 2 }
def fobj(a, ...) = a.each_with_object([], ...)
p fobj([1, 2]) { |x, acc| acc << x * 3 }
def fopt(a, b = 1, ...) = a.push(b, ...)
p fopt([0], 2, 3, 4)
def fput(...) = puts(...)
fput(5, 6)
