# An Array a method answers as the whole of a parenthesized body
# (`def keep(a) = (a << n)`) is the method's value, and holds the Strings of
# the program by handle. The climb that finds the method's value stopped at
# the parentheses, so an Array handed to such a method stayed a general one.
class K
  attr_reader :n

  def initialize = (@n = +"n")

  def keep(a) = (a << n)
end

k = K.new
a = []
k.keep(a)
a[0] << "!"
p k.n, a
