# An Array a method answers as the last statement of a parenthesized
# sequence that `return` hands out is the method's value, and holds the
# Strings of the program by handle. The climb that finds the method's value
# stopped at the sequence.
class K
  attr_reader :n
  def initialize = (@n = +"n")
  def keep(a)
    return (1; a << n)
  end
end
k = K.new
a = []
k.keep(a)
a[0] << "!"
p k.n, a
