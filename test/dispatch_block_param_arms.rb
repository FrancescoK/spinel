# A call with a block on a receiver whose class has subclasses overriding
# the method, every override taking the block as `&blk` (a bare `super`'s
# implicit forward included).

class A
  def m(x, &blk) = blk ? blk.call(x) : x

  def n(x, &blk)
    blk&.call(x)
    nil
  end

  def run = m(1) { |v| v * 100 }
end

class B < A
  def m(x) = super

  def n(x, &b)
    b.call(x * 2) if b
    nil
  end
end

class C < A
  def m(x, &blk) = blk ? "c#{blk.call(x)}" : "c"
end

class D < A
  def m(x) = super(x + 1)
end

[A.new, B.new, C.new, D.new].each { |o| p o.run }
p A.new.m(2) { |v| v + 1 }
p B.new.m(3) { |v| v + 1 }
p B.new.m(4)
p D.new.m(5) { |v| v * 3 }
A.new.n(5) { |v| p v }
B.new.n(6) { |v| p v }
@o = A.new
p @o.m(7) { |v| v - 1 }
