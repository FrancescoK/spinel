# An Array a method answers from a rescue clause is the method's value, and
# holds the Strings of the program by handle. The climb that finds the
# method's value stopped at a rescue clause.
class K
  attr_reader :n
  def initialize = (@n = +"n")
  def keep(a)
    begin
      raise "x" if a.size > 5
      a << n
    rescue
      a << n
    end
  end
end
k = K.new
a = []
k.keep(a)
a[0] << "!"
p k.n, a
