# A push through the class's own reader, in a program that also defines a
# user <<, types the backing array from what is pushed

class Br
  attr_reader :x
  def initialize(x) = @x = x
end
class Coll
  def <<(x) = self
end
class E
  attr_reader :branches
  def initialize = @branches = []
  def t(x)
    branches << b = Br.new(x)
    b
  end
end
e = E.new
e.t(1)
p e.branches.map(&:x)
