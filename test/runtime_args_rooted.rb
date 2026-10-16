# spinel: gc-stress
# A runtime helper holds what it was handed across its own allocations.
# Rational#coerce on a new boxed Rational, values_at on a boxed Array with a
# Range key, a block made from a Method (`&method(:m)`) and
# Socket.getaddrinfo each held a new object only in a C argument or local
# while they allocated, and under SPINEL_GC_STRESS=2 it was read back freed.
require "socket"
def rr = [Rational(1, 3), 1][0]
p rr.coerce(2), (rr * 2).coerce(3), (rr * 3).coerce(2.5)
class W
  def values_at(*a) = :w
end
x = [[1, 2, 3, 4], 1][0]
p x.values_at(0, 2..), x.values_at(1..2, -1), W.new.values_at(1)
def mm(a, k: 1) = [a, k]
def yl = yield(5, k: 6)
p yl(&method(:mm))
p Socket.getaddrinfo("127.0.0.1", 80, :INET, :STREAM).first.first(4)
