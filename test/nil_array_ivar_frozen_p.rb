# frozen? on an Array slot that holds nil: nil answers it (true). The typed
# read took the NULL slot as the Array and read its flag.
class Q
  def initialize(f) = (@r = f ? [1, "a"] : nil)
  def go = @r.frozen?
  def ints = (@i = nil; @i = [1] if @r; @i.frozen?)
end
p Q.new(false).go, Q.new(true).go, Q.new(false).ints, Q.new(true).ints
a = Q.new(true)
p a.instance_variable_get(:@r).freeze.frozen?
