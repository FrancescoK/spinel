# A value in parentheses entering or looked up in a Set that compares by
# identity is the value the parentheses answer: their last statement's, and
# nil for `()`. A collection, a block's value and map!'s block value in
# parentheses are judged the same way. The receiver of compare_by_identity
# in parentheses still makes the Set an identity one. A Pt equals another
# of the same n, so only an identity Set tells two of them apart.
require "set"

class Pt
  def initialize(n) = @n = n
  attr_reader :n
  def ==(o) = o.is_a?(Pt) && o.n == @n
  alias eql? ==
  def hash = @n.hash
end

a = Pt.new(1)
b = Pt.new(2)
x = 0
s = Set.new.compare_by_identity
s.add((x += 1; a))
s << (x += 1; :k)
s << ()
p s.size
p s.include?((x; a))
p s.include?(())
p s.include?((x; Pt.new(1)))
p x

# a collection and a block value in parentheses
t = Set.new((x += 1; [a, b])).compare_by_identity
p t.size
u = Set.new([a, b]) { |e| (x += 1; a) }
u.compare_by_identity
p u.size
t.map! { |e| (x += 1; e) }
p t.include?(b)
p x

# the receiver of compare_by_identity in parentheses
class Box
  def initialize
    @seen = Set.new
    (@n = 0; @seen).compare_by_identity
  end

  def add(v) = @seen.add(v)
  def size = @seen.size
end
bx = Box.new
bx.add(a)
bx.add(a)
bx.add(Pt.new(1))
bx.add(b)
p bx.size
