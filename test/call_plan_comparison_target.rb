# A comparison answers a Boolean while calling the planned <=> target.
class Score
  include Comparable
  def initialize(n) = @n = n
  attr_reader :n
  def <=>(other) = @n <=> other.n
end
left = Score.new(1)
right = Score.new(2)
p(left < right)
p(left <= right)
p(left > right)
p(left >= right)
