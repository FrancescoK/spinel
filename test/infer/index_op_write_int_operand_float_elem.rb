# `a[i] op= v` stores `a[i] op v`, not v. A Float element combined with an
# Integer operand is a Float, so `acc[i] /= 4` on a Float Array keeps it a
# Float Array. The write took the operand's type (Integer) as the stored
# value's, which met the Float element and widened the whole array to a boxed
# PolyArray: every read and write after that was boxed, and passing it to a
# parameter typed Array[Float] converted it into a copy at the call.
# `acc[i] = acc[i] / 4` was always typed right.
class OpwAcc
  def initialize(n)
    @acc = Array.new(n, 3.0)
  end

  def scale
    i = 0
    while i < @acc.length
      @acc[i] /= 2
      @acc[i] *= 3
      i += 1
    end
    @acc
  end
end

def opw_local(n)
  acc = Array.new(n, 2.5)
  i = 0
  while i < n
    acc[i] += 1
    acc[i] -= 2
    acc[i] %= 3
    acc[i] **= 2
    i += 1
  end
  acc
end

p OpwAcc.new(3).scale
p opw_local(3)

# An Integer element with a Float operand is a Float: that array does hold
# both kinds afterwards and must still widen.
def opw_mixed
  ia = [1, 2]
  ia[0] /= 2.0
  ia
end
p opw_mixed
