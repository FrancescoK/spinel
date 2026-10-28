# map(&:n) over an Enumerator lowers to `steps > 1 ? x.n(step[1]) : x.n`:
# the arm that passes an argument has no reader to answer it, and its value
# is read in the same form as it is emitted
class Day
  attr_reader :n
  def initialize(n) = @n = n
  def walk(k)
    return to_enum(:walk, k) unless block_given?
    yield Day.new(k)
    yield Day.new(k + 1)
    self
  end
end
p Day.new(0).walk(5).map(&:n)
