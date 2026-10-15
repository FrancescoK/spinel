# A block of map over an Enumerator that a method makes with to_enum and
# arguments, boxed beside the method's self: &:m, |*r| and |x| bind each
# step as CRuby does (#9271).
class Day
  attr_reader :n
  def initialize(n) = @n = n
  def walk(k)
    return to_enum(:walk, k) unless block_given?
    yield Day.new(k)
    yield Day.new(k + 1)
    self
  end
  def pairs(k)
    return to_enum(:pairs, k) unless block_given?
    yield k, Day.new(k)
    self
  end
end
p Day.new(0).walk(5).map(&:n)
p Day.new(0).walk(5).map { |*r| r.size }
p Day.new(0).walk(5).map { |d| d.n }
p Day.new(0).pairs(3).map { |*r| r.size }
p Day.new(0).pairs(3).map { |a| a }
p [[1, 2], [3]].map(&:first)
