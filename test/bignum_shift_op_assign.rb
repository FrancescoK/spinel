# `<<=` and `>>=` on a Bignum slot -- a local, an ivar, a global, a class
# variable -- shift as the binary `n = n >> k` does: a negative count
# shifts the other way, a boxed count is converted, and the value of the
# assignment is the new value

n = 2**100
n >>= 1
p n
n >>= -2
p n
x = (n >>= 3)
p x, n
n >>= 200
p n

m = 2**70
m <<= [1, "x"][0]
p m

class Box
  @@v = 2**75
  def initialize = (@v = 2**80)
  def halve = (@v >>= 1; @v)
  def self.dbl = (@@v <<= 1)
end
p Box.new.halve
p Box.dbl

$g = 2**90
$g <<= 3
p $g
