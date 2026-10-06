# Where a user class defines <, <=, > or >=, a boxed comparison goes
# through the user-operator dispatch (sp_poly_relop_v): two classes
# reaching the site answer by the class graph -- nil when unrelated, as
# Module#< does -- and the user's operator answers for its own objects.
class Money
  attr_reader :c
  def initialize(c) = @c = c
  def <(o) = o.is_a?(Money) ? c < o.c : :money
  def >=(o) = :ge
end
class A; end
class B < A; end
class C; end

def pick(i) = [Money.new(1), A, B, C, 7][i]

p [pick(1) < pick(3), pick(2) < pick(1), pick(1) < pick(2), pick(3) >= pick(1), pick(2) >= pick(1)]
p [Money.new(1) < Money.new(2), Money.new(1) >= Money.new(0), pick(4) < pick(4)]
