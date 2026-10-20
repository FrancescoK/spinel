# An Array a method answers as the body of a def with a rescue clause
# (`def keep(a); a << n; rescue; nil; end`) is the method's value, and holds
# the Strings of the program by handle. The climb that finds the method's
# value stopped at the implicit begin.
class K
  attr_reader :n
  def initialize = (@n = +"n")
  def keep(a)
    a << n
  rescue
    nil
  end
end
k = K.new
a = []
k.keep(a)
a[0] << "!"
p k.n, a
