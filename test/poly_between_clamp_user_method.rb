# between? and clamp on a value that may be an object of a class defining
# them: the object takes its own method, and a builtin value (or a
# Comparable object) the builtin's.

class Ver
  include Comparable
  attr_reader :n
  def initialize(n) = (@n = n)
  def <=>(o) = n <=> o.n
end

class Rec
  def between?(lo, hi) = :mine
  def clamp(*a) = a.size
end

def between_of(m, lo, hi) = m.between?(lo, hi)
def clamp2(m) = m.clamp(1, 5)
def clampr(m) = m.clamp(1..5)

p between_of(Rec.new, 1, 5)
p between_of(3, 1, 5), between_of(7.5, 1, 5)
p between_of(Ver.new(2), Ver.new(1), Ver.new(3))
p between_of("b", "a", "c")
begin
  between_of(nil, 1, 2)
rescue NoMethodError => e
  p e.class
end

p clamp2(Rec.new), clampr(Rec.new)
p clamp2(9), clampr(-3), clamp2(2.5), clampr(7.5)
