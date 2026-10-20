# An Array a method answers as the argument of `return`, in parentheses
# (`return (a << n)`, `return ((a << n))`), is the method's value, and holds
# the Strings of the program by handle. The climb that finds the method's
# value stopped at the parentheses.
class K
  attr_reader :n

  def initialize = (@n = +"n")

  def keep(a)
    return (a << n)
  end

  def keep2(a)
    return ((a << n))
  end
end

k = K.new
a = []
k.keep(a)
a[0] << "!"
p k.n, a
b = []
k.keep2(b)
b[0] << "?"
p k.n, b
