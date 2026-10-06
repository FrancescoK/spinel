# `x <<= n` and `x >>= n` take the binary operators' paths: a runtime count
# is range-checked and a slot that holds nil raises NoMethodError. The op-assign
# emitted a bare C shift, so `x <<= 70` answered 0 where `x << 70` raised,
# and `@x <<= 1` on an unset ivar shifted the nil sentinel into a number.
class Unset
  def shl
    @x <<= 1
  end
  def shr
    @x >>= 2
  end
end
begin
  Unset.new.shl
rescue NoMethodError => e
  p e.class
end
begin
  Unset.new.shr
rescue NoMethodError => e
  p e.class
end

x = 3
n = 4
x <<= n
p x
x >>= n
p x
n = -2
x <<= n
p x
x = 1024
x >>= 3
p x
x <<= 2
p x

class Acc
  def initialize; @v = 5; end
  def go(k)
    @v <<= k
    @v >>= 1
    @v
  end
end
p Acc.new.go(6)
