# `x == <Bignum>` on a boxed x (an Integer, nil or a String), where a program class's == answers
# something other than a bool so the comparison's value is boxed: the
# Bignum comparison answers true or false into that boxed value (an `||`
# beside it). It was a C int stored into the boxed slot, which did not
# compile.

class Loose
  def ==(other) = nil
end

def masked(x) = x & 0x1_0000_0000_0000_0000 == 0x1_0000_0000_0000_0000 || :no
def differs(x) = x != 0x2_0000_0000_0000_0000 && :yes

p masked(0x3_0000_0000_0000_0000)
p masked(1)
p masked(nil)
p differs(0x2_0000_0000_0000_0000)
p differs(5)
p differs("s")
p(Loose.new == 3)
