# A class including Enumerable whose attr_reader is named like an
# Enumerable method (activesupport's CallbackChain reads `other.chain`)
# answers the reader: the call was rewritten into the builtin's
# Enumerable#chain / #zip over the class's each, typed or boxed.
class Chain
  include Enumerable
  def initialize(xs) = (@chain = xs; @zip = xs.size)
  def each(&b) = @chain.each(&b)
  def initialize_copy(other)
    @chain = other.chain.dup
  end
  def add(x) = (@chain << x; self)
  def peer(other) = other.chain
  attr_reader :zip
  protected
    attr_reader :chain
end

def boxed(x) = x

a = Chain.new([1, 2])
b = a.dup
b.add(3)
p a.to_a, b.to_a
p a.peer(b)
p a.zip, boxed([a, 1][0]).zip
c = boxed([a, "s"][0]).dup
c.add(9)
p c.to_a, a.to_a
p [1, 2].chain([3]).to_a, [1, 2].zip([3, 4])
