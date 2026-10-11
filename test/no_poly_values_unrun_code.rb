# The types of code the program never runs do not make it a program with
# poly values (#8401): a method nothing calls, and the Enumerable helper the
# compiler adds for a class with #each. (An FFI directive's arguments are
# checked by infer-test.)
class Pairs
  def initialize(n) = @n = n
  def each
    yield @n
    yield @n + 1
  end
end
def unused
  [1, 2]
end
module Fn
  def self.run
    s = 0
    Pairs.new(4).each { |x| s += x }
    s
  end
end
p Fn.run
