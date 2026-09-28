# `@x |= v`, `&=` and `^=` on an ivar nothing has assigned yet start from nil,
# so they answer NilClass#|, #& and #^ (true, false, v's truthiness), not an
# Integer bit pattern (#5470); an ivar initialized to an Integer still ORs.
class Opts
  def set(bit); @options |= bit; self; end
  def to_i; @options; end
end
p Opts.new.set(256).to_i
x = nil
x |= 3
p x
class Opts2
  def initialize = @flags = 0
  def set(bit) = (@flags |= bit; self)
  def to_i = @flags
end
p Opts2.new.set(256).set(1).to_i
class M
  def a(v) = (@m &= v; @m)
  def x(v) = (@n ^= v; @n)
end
p M.new.a(3), M.new.x(3), M.new.x(nil)
class L
  def set(b) = (@o |= b; self)
  def o = @o
end
l = L.new.set(4)
p l.o
l.set(1)
p l.o
